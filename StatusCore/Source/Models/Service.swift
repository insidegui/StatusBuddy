//
//  Service.swift
//  StatusCore
//
//  Created by Guilherme Rambo on 11/02/20.
//  Copyright © 2020 Guilherme Rambo. All rights reserved.
//

import Foundation

public struct Service: Hashable, Codable {

    public struct Event: Hashable, Codable {
        public let epochStartDate: Date?
        public let epochEndDate: Date?
        public let message: String
        public let eventStatus: String
    }

    public let serviceName: String
    public let redirectUrl: String?
    public let events: [Event]
}

public extension Service {
    var eventsSortedByEndDate: [Event] {
        events.sorted(by: { ($0.epochEndDate ?? .distantPast) < ($1.epochEndDate ?? .distantPast) })
    }
}
