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
            subtitle: Self.subtitle(for: type, in: service)
        )
    }
    
    private static func subtitle(for type: EventFilter, in service: Service) -> String? {
        service.events(filteredBy: type).sorted(by: { $0.nonOptionalStartDate > $1.nonOptionalStartDate }).first?.message
    }
    
}


private extension Service.Event {
    var nonOptionalStartDate: Date { epochStartDate ?? .distantPast }
}
