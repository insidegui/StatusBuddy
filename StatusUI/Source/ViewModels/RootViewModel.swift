//
//  RootViewModel.swift
//  StatusUI
//
//  Created by Guilherme Rambo on 29/06/21.
//  Copyright © 2021 Guilherme Rambo. All rights reserved.
//

import Foundation
import Observation
import OSLog
import StatusCore

@MainActor
@Observable
public final class RootViewModel {
    
    public private(set) var latestResponses: [ServiceScope: StatusResponse] = [:]
    private(set) var dashboard = DashboardViewModel()
    private(set) var details: [ServiceScope: DetailViewModel] = [:]
    private(set) var overviews: [ServiceCategory: ServiceOverview] = [:]
    private(set) var lastUpdated: Date?
    private(set) var isRefreshing = false
    public private(set) var hasActiveIssues = false
    
    @ObservationIgnored public var showSettingsMenu: () -> Void = { }
    
    private let logger = Logger(subsystem: StatusUI.subsystemName, category: String(describing: RootViewModel.self))
    
    let checkers: [ServiceScope: StatusChecker]
    let updateInterval: TimeInterval
    
    private static var deafultRefreshInterval: TimeInterval {
        if let refreshStr = UserDefaults.standard.string(forKey: "SBRefreshInterval"), let refreshInt = Int(refreshStr) {
            return TimeInterval(refreshInt)
        } else {
            return 10 * 60
        }
    }
    
    public init(with checkers: [ServiceScope: StatusChecker] = [:],
                dashboard: DashboardViewModel = DashboardViewModel())
    {
        self.checkers = checkers
        self.dashboard = dashboard
        self.updateInterval = Self.deafultRefreshInterval
    }

    private var updateTimer: Timer?
    
    public func startPeriodicUpdates() {
        guard updateTimer == nil else { return }

        logger.debug("\(#function, privacy: .public)")

        updateTimer = Timer.scheduledTimer(withTimeInterval: updateInterval, repeats: true, block: { [weak self] _ in
            Task { @MainActor in
                self?.refresh(nil)
            }
        })
        updateTimer?.tolerance = updateInterval / 3
        
        refresh(nil)
    }
    
    public func stopPeriodicUpdates() {
        logger.debug("\(#function, privacy: .public)")
        
        updateTimer?.invalidate()
        updateTimer = nil
    }
    
    @ObservationIgnored private var inFlightRefresh: Task<Void, Never>?
    
    public func refresh(_ completion: (() -> Void)? = nil) {
        logger.debug("\(#function, privacy: .public)")
        
        inFlightRefresh?.cancel()
        isRefreshing = true
        inFlightRefresh = Task { [weak self, checkers] in
            do {
                let results = try await withThrowingTaskGroup(of: (ServiceScope, StatusResponse).self) { group in
                    for (scope, checker) in checkers {
                        group.addTask { (scope, try await checker.check()) }
                    }
                    return try await group.reduce(into: []) { $0.append($1) }
                }

                guard let self, !Task.isCancelled else { return }

                update(with: Dictionary(uniqueKeysWithValues: results))
            } catch is CancellationError {
                return
            } catch {
                guard let self, !Task.isCancelled else { return }
                logger.error("Status check failed with error: \(String(describing: error), privacy: .public)")
                dashboard = DashboardViewModel(with: .failure(String(describing: error)))
            }

            self?.isRefreshing = false
            completion?()
        }
    }

    private func update(with responses: [ServiceScope: StatusResponse]) {
        latestResponses = responses
        details = responses.reduce(into: [:]) { result, entry in
            result[entry.key] = DetailViewModel(with: entry.value, in: entry.key)
        }
        hasActiveIssues = responses.values.contains(where: \.hasActiveEvents)
        dashboard = DashboardViewModel(with: responses)
        overviews = Dictionary(uniqueKeysWithValues: ServiceCategory.allCases.map {
            ($0, ServiceOverview(details: details, category: $0))
        })
        lastUpdated = Date()
    }
    
}

public extension RootViewModel {
    static let `default` = RootViewModel(with: [
        .developer: AppleStatusChecker(endpoint: .developerFeedURL, format: .JSONCallback),
        .customer: AppleStatusChecker(endpoint: .consumerFeedURL, format: .JSON)
    ])

    #if DEBUG
    internal static func preview(with responses: [ServiceScope: StatusResponse]) -> RootViewModel {
        let model = RootViewModel()
        model.update(with: responses)
        return model
    }

    static let preview = try! RootViewModel(with: [
        .developer: PreviewStatusChecker(responses: [.developerNoIssues(), .developerOneOngoingIssue(), .developerOneResolvedIssue(), .developerOneScheduledIssue()]),
        .customer: PreviewStatusChecker(responses: [.customerNoIssues(), .customerOneOngoingIssue(), .customerThreeOngoingIssues(), .customerThreeResolvedIssues()])
    ])
    #endif
}

extension URL {
    static var developerFeedURL: URL {
        if let overrideStr = UserDefaults.standard.string(forKey: "SBDeveloperFeedURL"),
           let overrideURL = URL(string: overrideStr) {
            return overrideURL
        } else {
            return URL(string: "https://www.apple.com/support/systemstatus/data/developer/system_status_en_US.js?callback=jsonCallback")!
        }
    }

    static var consumerFeedURL: URL {
        if let overrideStr = UserDefaults.standard.string(forKey: "SBConsumerFeedURL"),
           let overrideURL = URL(string: overrideStr) {
            return overrideURL
        } else {
            return URL(string: "https://www.apple.com/support/systemstatus/data/system_status_en_US.js")!
        }
    }
}
