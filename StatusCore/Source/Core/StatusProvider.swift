//
//  StatusProvider.swift
//  StatusCore
//
//  Created by Guilherme Rambo on 11/02/20.
//  Copyright © 2020 Guilherme Rambo. All rights reserved.
//

import Foundation
import Combine

typealias ServiceEventFilter = (Service.Event) -> Bool
typealias AnyServiceEventPublisher = AnyPublisher<[Service.Event], Never>

public final class StatusProvider: ObservableObject {

    @Published public var developerServices: [Service] = []
    @Published public var consumerServices: [Service] = []

    @Published public var activeIssues: [Service.Event] = []
    @Published public var resolvedIssues: [Service.Event] = []

    @Published public var isPerformingInitialLoad = true

    private var developerFeedURL: URL {
        if let overrideStr = UserDefaults.standard.string(forKey: "SBDeveloperFeedURL"),
            let overrideURL = URL(string: overrideStr) {
            return overrideURL
        } else {
            return URL(string: "https://www.apple.com/support/systemstatus/data/developer/system_status_en_US.js?callback=jsonCallback")!
        }
    }

    private var consumerFeedURL: URL {
        if let overrideStr = UserDefaults.standard.string(forKey: "SBConsumerFeedURL"),
            let overrideURL = URL(string: overrideStr) {
            return overrideURL
        } else {
            return URL(string: "https://www.apple.com/support/systemstatus/data/system_status_en_US.js")!
        }
    }

    public private(set) lazy var developerChecker: StatusChecker = {
        StatusChecker(endpoint: developerFeedURL)
    }()

    public private(set) lazy var consumerChecker: StatusChecker = {
        StatusChecker(endpoint: consumerFeedURL)
    }()

    private var cancellables: [Cancellable] = []

    private func mapIssues(in publisher: Published<StatusResponse?>.Publisher,
                           filter: @escaping ServiceEventFilter) -> AnyServiceEventPublisher
    {
        publisher
            .map({ $0?.services })
            .replaceNil(with: [Service]())
            .map({ $0.compactMap({ $0.events.sorted(by: { ($0.epochEndDate ?? .distantPast) < ($1.epochEndDate ?? .distantPast) }).last }) })
            .map({ $0.filter({ filter($0) }) })
            .catch({ _ in Empty<[Service.Event], Never>() })
            .eraseToAnyPublisher()
    }

    public init() {
        let developerLoaded = developerChecker.$currentStatus.map({ $0 == nil ? false : true })
        let consumerLoaded = consumerChecker.$currentStatus.map({ $0 == nil ? false : true })

        let finishedLoad = developerLoaded.combineLatest(consumerLoaded, { $0 || $1 }).map({ !$0 })
        let initialLoadFinishedBinding = finishedLoad.assign(to: \.isPerformingInitialLoad, on: self)

        cancellables.append(initialLoadFinishedBinding)

        let activeDeveloperIssuesPublisher = mapIssues(in: developerChecker.$currentStatus, filter: { $0.epochEndDate == nil } )
        let activeConsumerIssuesPublisher = mapIssues(in: consumerChecker.$currentStatus, filter: { $0.epochEndDate == nil } )
        let activeIssuesPublisher = activeDeveloperIssuesPublisher.combineLatest(activeConsumerIssuesPublisher).map({ $0.0 + $0.1 })
        let activeIssuesBinding = activeIssuesPublisher.assign(to: \.activeIssues, on: self)

        cancellables.append(activeIssuesBinding)

        let resolvedDeveloperIssuesPublisher = mapIssues(in: developerChecker.$currentStatus, filter: { $0.epochEndDate != nil } )
        let resolvedConsumerIssuesPublisher = mapIssues(in: consumerChecker.$currentStatus, filter: { $0.epochEndDate != nil } )
        let resolvedIssuesBinding = resolvedDeveloperIssuesPublisher.append(resolvedConsumerIssuesPublisher).assign(to: \.resolvedIssues, on: self)

        cancellables.append(resolvedIssuesBinding)

        let developerBinding = developerChecker.$currentStatus
            .map({ $0?.services })
            .replaceNil(with: [Service]())
            .assign(to: \.developerServices, on: self)

        cancellables.append(developerBinding)

        let consumerBinding = consumerChecker.$currentStatus
            .map({ $0?.services })
            .replaceNil(with: [Service]())
            .assign(to: \.consumerServices, on: self)

        cancellables.append(consumerBinding)
    }

    public func check() {
        developerChecker.clear()
        consumerChecker.clear()

        isPerformingInitialLoad = true
        
        developerChecker.check()
        consumerChecker.check()
    }

}
