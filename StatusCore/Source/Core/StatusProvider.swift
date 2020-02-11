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
typealias AnyServiceEventPublisher = AnyPublisher<Set<Service.Event>, Never>

public final class StatusProvider: ObservableObject {

    @Published public var developerServices: [Service] = []
    @Published public var consumerServices: [Service] = []

    @Published public var activeIssues = Set<Service.Event>()
    @Published public var resolvedIssues = Set<Service.Event>()

    public private(set) lazy var developerChecker: StatusChecker = {
        StatusChecker(endpoint: URL(string: "https://www.apple.com/support/systemstatus/data/developer/system_status_en_US.js?callback=jsonCallback")!)
    }()

    public private(set) lazy var consumerChecker: StatusChecker = {
        StatusChecker(endpoint: URL(string: "https://www.apple.com/support/systemstatus/data/system_status_en_US.js")!)
    }()

    private var cancellables: [Cancellable] = []

    private func mapIssues(in publisher: Published<StatusResponse?>.Publisher,
                           filter: @escaping ServiceEventFilter) -> AnyServiceEventPublisher
    {
        publisher
            .map({ $0?.services })
            .replaceNil(with: [Service]())
            .map({ $0.flatMap({ $0.events }) })
            .map({ Set($0) })
            .catch({ _ in Empty<Set<Service.Event>, Never>() })
            .eraseToAnyPublisher()
    }

    public init() {
        let activeDeveloperIssuesPublisher = mapIssues(in: developerChecker.$currentStatus, filter: { $0.epochEndDate == nil } )
        let activeConsumerIssuesPublisher = mapIssues(in: consumerChecker.$currentStatus, filter: { $0.epochEndDate == nil } )
        let activeIssuesBinding = activeDeveloperIssuesPublisher.append(activeConsumerIssuesPublisher).assign(to: \.activeIssues, on: self)

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
        developerChecker.check()
        consumerChecker.check()
    }

}
