//
//  DetailGroup+StatusCore.swift
//  StatusUI
//
//  Created by Guilherme Rambo on 01/07/21.
//  Copyright © 2021 Guilherme Rambo. All rights reserved.
//

import Foundation
import StatusCore
import SwiftUI

extension DetailGroup {
    
    static func generateGroups(with response: StatusResponse, in scope: ServiceScope) -> [DetailGroup] {
        let servicesWithOngoingIssues = response.services.filter { $0.hasActiveEvents }
        let servicesWithScheduledIssues = response.services.filter { $0.hasScheduledEvents }
        let servicesWithRecentIssues = response.services.filter { $0.hasRecentEvents && !$0.hasActiveEvents }
        let servicesWithoutIssues = response.services.filter { !$0.hasRecentEvents && !$0.hasActiveEvents }
        
        let scheduledIssueItems = servicesWithScheduledIssues.compactMap { DetailGroupItem(for: .scheduled, in: $0) }
        let ongoingIssueItems = servicesWithOngoingIssues.compactMap { DetailGroupItem(for: .ongoing, in: $0) }
        let recentIssueItems = servicesWithRecentIssues.compactMap { DetailGroupItem(for: .recent, in: $0) }
        let operationalItems = servicesWithoutIssues.compactMap({ DetailGroupItem(for: .operational, in: $0) })
        
        var groups: [DetailGroup] = []

        if !scheduledIssueItems.isEmpty {
            let group = DetailGroup(
                id: "SCHEDULED",
                scope: scope,
                iconName: "calendar",
                title: "SCHEDULED MAINTENANCE",
                accentColor: .scheduledIssue,
                supportsNotifications: false,
                items: scheduledIssueItems
            )
            groups.append(group)
        }

        if !ongoingIssueItems.isEmpty {
            let group = DetailGroup(
                id: "ONGOING",
                scope: scope,
                iconName: "x.circle.fill",
                title: "ACTIVE ISSUES",
                accentColor: .error,
                supportsNotifications: true,
                items: ongoingIssueItems
            )
            groups.append(group)
        }
        
        if !recentIssueItems.isEmpty {
            let group = DetailGroup(
                id: "RECENT",
                scope: scope,
                iconName: "exclamationmark.triangle.fill",
                title: "RECENT ISSUES",
                accentColor: .warningText,
                supportsNotifications: false,
                items: recentIssueItems
            )
            groups.append(group)
        }
        
        if !operationalItems.isEmpty {
            let group = DetailGroup(
                id: "OPERATIONAL",
                scope: scope,
                iconName: "checkmark.circle.fill",
                title: "OPERATIONAL",
                accentColor: .success,
                supportsNotifications: false,
                items: operationalItems
            )
            groups.append(group)
        }
        
        return groups
    }
    
}

extension DetailGroupItem {
    
    init(for type: EventFilter, in service: Service) {
        self.init(
            id: service.serviceName,
            title: service.serviceName,
            subtitle: Self.subtitle(for: type, in: service),
            formattedResolutionTime: Self.formattedResolutionTime(for: type, in: service),
            formattedScheduledStartTime: Self.formattedScheduledStartTime(for: service),
            formattedScheduledEndTime: Self.formattedScheduledEndTime(for: service)
        )
    }
    
    private static func relevantEvent(for type: EventFilter, in service: Service) -> Service.Event? {
        if type == .scheduled {
            return service.events(filteredBy: type).sorted(by: { $0.nonOptionalFutureEndDate > $1.nonOptionalFutureEndDate }).first
        } else {
            return service.events(filteredBy: type).sorted(by: { $0.nonOptionalStartDate > $1.nonOptionalStartDate }).first
        }
    }
    
    private static func subtitle(for type: EventFilter, in service: Service) -> String? {
        relevantEvent(for: type, in: service)?.message
    }

    private static func formattedScheduledStartTime(for service: Service) -> String? {
        guard let event = relevantEvent(for: .scheduled, in: service), let startDate = event.epochStartDate, startDate > Date() else { return nil }
        return Self.scheduledStartDateFormatter.string(from: startDate)
    }

    private static func formattedScheduledEndTime(for service: Service) -> String? {
        guard let event = relevantEvent(for: .scheduled, in: service), let endDate = event.epochEndDate, endDate > Date() else { return nil }
        
        if Calendar(identifier: .gregorian).isDate(event.nonOptionalStartDate, inSameDayAs: endDate) {
            return Self.scheduledEndDateFormatterTimeOnly.string(from: endDate)
        } else {
            return Self.scheduledEndDateFormatter.string(from: endDate)
        }
    }

    private static func formattedResolutionTime(for type: EventFilter, in service: Service) -> String? {
        guard let event = relevantEvent(for: type, in: service), let endDate = event.epochEndDate else { return nil }
        return Self.endDateFormatter.string(from: endDate)
    }
    
    static let endDateFormatter: DateFormatter = {
        let f = DateFormatter()
        
        f.doesRelativeDateFormatting = true
        f.timeStyle = .short
        f.dateStyle = .short
        f.formattingContext = .middleOfSentence
        
        return f
    }()

    static let scheduledStartDateFormatter: DateFormatter = {
        let f = DateFormatter()

        f.doesRelativeDateFormatting = true
        f.timeStyle = .short
        f.dateStyle = .short
        f.formattingContext = .beginningOfSentence

        return f
    }()

    static let scheduledEndDateFormatter: DateFormatter = {
        let f = DateFormatter()

        f.doesRelativeDateFormatting = true
        f.timeStyle = .short
        f.dateStyle = .short
        f.formattingContext = .beginningOfSentence

        return f
    }()

    static let scheduledEndDateFormatterTimeOnly: DateFormatter = {
        let f = DateFormatter()

        f.doesRelativeDateFormatting = false
        f.timeStyle = .short
        f.dateStyle = .none
        f.formattingContext = .middleOfSentence

        return f
    }()
}


private extension Service.Event {
    var nonOptionalStartDate: Date { epochStartDate ?? .distantPast }
    var nonOptionalFutureEndDate: Date {
        guard let epochEndDate, epochEndDate > Date() else { return .distantPast }
        return epochEndDate
    }
}

extension Color {
    static let scheduledIssue: Color = {
        if #available(macOS 12.0, *) {
            return .indigo
        } else {
            return .purple
        }
    }()
}
