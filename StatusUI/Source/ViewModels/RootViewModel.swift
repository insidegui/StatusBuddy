//
//  RootViewModel.swift
//  StatusUI
//
//  Created by Guilherme Rambo on 29/06/21.
//  Copyright © 2021 Guilherme Rambo. All rights reserved.
//

import Foundation
import Combine
import os.log
import StatusCore

public final class RootViewModel: ObservableObject {
    
    @Published public var selectedDashboardItem: DashboardItem?
    @Published public private(set) var latestResponses: [ServiceScope: StatusResponse] = [:]
    @Published private(set) var dashboard = DashboardViewModel()
    @Published private(set) var details: [ServiceScope: DetailViewModel] = [:]
    @Published public private(set) var hasActiveIssues = false
    
    public var showSettingsMenu: () -> Void = { }
    
    private let log = OSLog(subsystem: StatusUI.subsystemName, category: String(describing: RootViewModel.self))
    
    let checkers: [ServiceScope: StatusChecker]
    let updateInterval: TimeInterval
    
    private lazy var cancellables = Set<AnyCancellable>()

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
        self.updateInterval = Self.deafultRefreshInterval
        
        $latestResponses.map({ $0.values.contains(where: { $0.hasActiveEvents }) }).assign(to: &$hasActiveIssues)
    }

    private var updateTimer: Timer?
    
    public func startPeriodicUpdates() {
        guard updateTimer == nil else { return }

        os_log("%{public}@", log: log, type: .debug, #function)

        updateTimer = Timer.scheduledTimer(withTimeInterval: updateInterval, repeats: true, block: { [weak self] _ in
            self?.refresh(nil)
        })
        updateTimer?.tolerance = updateInterval / 3
        
        refresh(nil)
    }
    
    public func stopPeriodicUpdates() {
        os_log("%{public}@", log: log, type: .debug, #function)
        
        updateTimer?.invalidate()
        updateTimer = nil
    }
    
    private var inFlightRefresh: Cancellable?
    
    public func refresh(_ completion: (() -> Void)? = nil) {
        os_log("%{public}@", log: log, type: .debug, #function)
        
        inFlightRefresh?.cancel()
        inFlightRefresh = nil
        
        let publishers = checkers.map { scope, checker in
            checker.check().map { (scope, $0) }
        }
        
        inFlightRefresh = Publishers.MergeMany(publishers).collect().sink { [weak self] result in
            guard let self = self else { return }
            
            if case .failure(let error) = result {
                os_log("Status check failed with error: %{public}@", log: self.log, type: .error, String(describing: error))
                
                self.dashboard = DashboardViewModel(with: .failure(String(describing: error)))
            }
            
            completion?()
        } receiveValue: { [weak self] results in
            guard let self = self else { return }
            
            results.forEach { scope, response in
                self.latestResponses[scope] = response
                self.details[scope] = DetailViewModel(with: response, in: scope)
            }

            self.dashboard = DashboardViewModel(with: self.latestResponses)
        }
    }
    
}
