//
//  Colors.swift
//  StatusBuddyNewUIPrototype
//
//  Created by Guilherme Rambo on 28/06/21.
//

import SwiftUI
import Cocoa

extension Color {
    static let primaryText = Color(NSColor.labelColor)
    static let secondaryText = Color(NSColor.secondaryLabelColor)
    static let accent = Color(NSColor.controlAccentColor)
    static let success = Color("SuccessColor", bundle: .statusUI)
    static let warning = Color("WarningColor", bundle: .statusUI)
    static let warningText = Color("WarningTextColor", bundle: .statusUI)
    static let error = Color("ErrorColor", bundle: .statusUI)
    static let background = Color(NSColor.windowBackgroundColor)
    static let groupSeparator = Color("GroupSeparator", bundle: .statusUI)

    static let itemBackground = Color(NSColor(name: .init("itemBackground"), dynamicProvider: { appearance in
        if appearance.bestMatch(from: [.aqua, .darkAqua]) == .darkAqua {
            return NSColor(named: .init("ItemBackgroundDark"), bundle: .statusUI)!
        } else {
            return .windowBackgroundColor
        }
    }))
}
