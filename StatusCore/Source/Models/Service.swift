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
        
        static let resolvedStatuses = ["resolved", "completed"]
    }

    public let serviceName: String
    public let redirectUrl: String?
    public let events: [Event]
}

public extension Service {
    var eventsSortedByStartDateDescending: [Event] {
        events.sorted(by: { ($0.epochStartDate ?? .distantPast) > ($1.epochStartDate ?? .distantPast) })
    }
    
    var latestEvent: Event? { eventsSortedByStartDateDescending.first }
}

public extension Service {
    var activeEvents: [Event] { events.filter { !Event.resolvedStatuses.contains($0.eventStatus) } }
    var recentEvents: [Event] { events.filter { Event.resolvedStatuses.contains($0.eventStatus) } }
    
    var hasActiveEvents: Bool { !activeEvents.isEmpty }
    var hasRecentEvents: Bool { !recentEvents.isEmpty }
}
