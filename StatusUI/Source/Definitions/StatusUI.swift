//
//  StatusUI.swift
//  StatusUI
//
//  Created by Guilherme Rambo on 29/06/21.
//  Copyright © 2021 Guilherme Rambo. All rights reserved.
//

import Cocoa

public struct StatusUI {
    static let subsystemName = "codes.rambo.StatusBuddy.StatusUI"
    
    public static var transitionDuration: TimeInterval {
        if NSApp.currentEvent?.modifierFlags.contains(.shift) == true {
            return 10
        } else {
            return 0.5
        }
    }
}
