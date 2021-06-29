//
//  DetailGroup.swift
//  StatusBuddyNewUIPrototype
//
//  Created by Guilherme Rambo on 28/06/21.
//

import SwiftUI

struct DetailGroupItem: Hashable, Identifiable {
    let id: String
    let title: String
    let subtitle: String?
}

struct DetailGroup: Hashable, Identifiable {
    let id: String
    let iconName: String
    let title: String
    let accentColor: Color
    let supportsNotifications: Bool
    let items: [DetailGroupItem]
}
