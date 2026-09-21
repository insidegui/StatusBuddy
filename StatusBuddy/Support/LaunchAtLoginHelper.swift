//
//  LaunchAtLoginHelper.swift
//  StatusBuddy
//
//  Created by Guilherme Rambo on 21/12/21.
//  Copyright © 2021 Guilherme Rambo. All rights reserved.
//

import Cocoa
import ServiceManagement

struct LaunchAtLoginFailure: LocalizedError, CustomStringConvertible {
    let message: String

    init(_ message: LocalizedStringResource) {
        self.message = String(localized: message)
    }

    var errorDescription: String? { message }

    var description: String { message }

    static let enable = LaunchAtLoginFailure("StatusBuddy couldn’t enable launch at login. Make sure StatusBuddy is enabled in System Settings > General > Login Items & Extensions.")
    static let disable = LaunchAtLoginFailure("Sorry, disabling launch at login failed. Make sure that you don't have multiple copies of the app on your Mac.")
}

protocol LaunchAtLoginProvider: AnyObject {
    func checkEnabled() -> Bool
    func setEnabled(_ enabled: Bool) -> LaunchAtLoginFailure?
}

final class LaunchAtLoginHelper: LaunchAtLoginProvider {
    
    static let helperAppIdentifier = "tech.buddysoftware.StatusBuddyHelper"

    // Keep using the existing helper so login items enabled by earlier app versions
    // retain their registration without requiring the user to enable them again.
    private let service = SMAppService.loginItem(identifier: helperAppIdentifier)
    
    func checkEnabled() -> Bool {
        service.status == .enabled
    }
    
    func setEnabled(_ enabled: Bool) -> LaunchAtLoginFailure? {
        #if DEBUG
        guard !UserDefaults.standard.bool(forKey: "SBSimulateLaunchAtLoginEnablementError") else {
            return .enable
        }
        #endif
        
        do {
            if enabled {
                try service.register()
                guard service.status == .enabled else { return .enable }
            } else {
                try service.unregister()
            }
            return nil
        } catch {
            return enabled ? .enable : .disable
        }
    }

    static func openSystemSettings() {
        SMAppService.openSystemSettingsLoginItems()
    }

}
