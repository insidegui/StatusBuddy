//
//  DetailGroup+StatusCore.swift
//  StatusUI
//
//  Created by Guilherme Rambo on 01/07/21.
//  Copyright © 2021 Guilherme Rambo. All rights reserved.
//

import Foundation
import StatusCore

extension DetailGroup {
    
    static func generateGroups(with response: StatusResponse, in scope: ServiceScope) -> [DetailGroup] {
        let servicesWithOngoingIssues = response.services.filter { $0.hasActiveEvents }
        let servicesWithRecentIssues = response.services.filter { $0.hasRecentEvents && !$0.hasActiveEvents }
        let servicesWithoutIssues = response.services.filter { !$0.hasRecentEvents && !$0.hasActiveEvents }
        
        let ongoingIssueItems = servicesWithOngoingIssues.compactMap { DetailGroupItem(for: .ongoing, in: $0) }
        let recentIssueItems = servicesWithRecentIssues.compactMap { DetailGroupItem(for: .recent, in: $0) }
        let operationalItems = servicesWithoutIssues.compactMap({ DetailGroupItem(for: .operational, in: $0) })
        
        var groups: [DetailGroup] = []
        
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
            formattedResolutionTime: Self.formattedResolutionTime(for: type, in: service)
        )
    }
    
    private static func relevantEvent(for type: EventFilter, in service: Service) -> Service.Event? {
        service.events(filteredBy: type).sorted(by: { $0.nonOptionalStartDate > $1.nonOptionalStartDate }).first
    }
    
    private static func subtitle(for type: EventFilter, in service: Service) -> String? {
        relevantEvent(for: type, in: service)?.message
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
    
}


private extension Service.Event {
    var nonOptionalStartDate: Date { epochStartDate ?? .distantPast }
}
