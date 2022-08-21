//
//  DashboardItem+StatusCore.swift
//  StatusUI
//
//  Created by Guilherme Rambo on 30/06/21.
//  Copyright © 2021 Guilherme Rambo. All rights reserved.
//

import SwiftUI
import StatusCore

extension DashboardItem {
    init(with response: StatusResponse, in scope: ServiceScope) {
        self.init(
            with: scope,
            subtitle: Self.subtitle(with: response),
            iconColor: Self.iconColor(for: response),
            subtitleColor: Self.subtitleColor(for: response)
        )
    }
}

fileprivate extension DashboardItem {
    static func subtitle(with response: StatusResponse) -> String {
        let servicesWithActiveIssues = response.services.filter({ $0.hasActiveEvents })
        
        if servicesWithActiveIssues.count == 0 {
            let servicesWithRecentIssues = response.services.filter({ $0.hasRecentEvents })
            
            if servicesWithRecentIssues.count == 0 {
                return "All Systems Operational"
            } else if servicesWithRecentIssues.count == 1 {
                return String(format: "Recent Issue: %@", servicesWithRecentIssues[0].serviceName)
            } else {
                return String(format: "%d Recent Issues", servicesWithRecentIssues.count)
            }
        } else if servicesWithActiveIssues.count == 1 {
            return String(format: "Outage: %@", servicesWithActiveIssues[0].serviceName)
        } else {
            return String(format: "%d Ongoing Issues", servicesWithActiveIssues.count)
        }
    }
    
    static func subtitleColor(for response: StatusResponse) -> Color {
        if response.hasActiveEvents {
            return .error
        } else if response.hasRecentEvents {
            return .warningText
        } else {
            return .secondaryText
        }
    }
    
    static func iconColor(for response: StatusResponse) -> Color {
        if response.hasActiveEvents {
            return .error
        } else if response.hasRecentEvents {
            return .warning
        } else {
            return .accent
        }
    }
}
