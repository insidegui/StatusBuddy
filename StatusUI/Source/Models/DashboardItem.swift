//
//  DashboardItem.swift
//  StatusBuddyNewUIPrototype
//
//  Created by Guilherme Rambo on 28/06/21.
//

import SwiftUI

public struct DashboardItem: Hashable, Identifiable {
    public var id: String { scope.id }
    var title: String { scope.title }
    var iconName: String { scope.iconName }
    
    let scope: ServiceScope
    let subtitle: String
    let iconColor: Color
    let subtitleColor: Color
    
    public init(with scope: ServiceScope,
         subtitle: String? = nil,
         iconColor: Color? = nil,
         subtitleColor: Color? = nil)
    {
        self.scope = scope
        self.subtitle = subtitle ?? "All Systems Operational"
        self.iconColor = iconColor ?? .accent
        self.subtitleColor = subtitleColor ?? .secondaryText
    }
}
