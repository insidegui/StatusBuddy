//
//  Preferences.swift
//  StatusBuddy
//
//  Created by Guilherme Rambo on 11/02/20.
//  Copyright © 2020 Guilherme Rambo. All rights reserved.
//

import Foundation
import Observation

@Observable
@MainActor
final class Preferences {
    
    static let forPreviews = Preferences(defaults: UserDefaults(), launchAtLogin: PreviewLaunchAtLoginProvider())

    private var appURL: URL { Bundle.main.bundleURL }

    let defaults: UserDefaults
    private let launchAtLogin: LaunchAtLoginProvider
    
    private struct Keys {
        static let enableTimeSensitiveNotifications = "enableTimeSensitiveNotifications"
    }

    init(defaults: UserDefaults = .standard,
         launchAtLogin: LaunchAtLoginProvider = LaunchAtLoginHelper())
    {
        self.defaults = defaults
        self.launchAtLogin = launchAtLogin
        self.isLaunchAtLoginEnabled = launchAtLogin.checkEnabled()
        
        self.defaults.register(defaults: [
            Keys.enableTimeSensitiveNotifications: true
        ])
        
        enableTimeSensitiveNotifications = defaults.bool(forKey: Keys.enableTimeSensitiveNotifications)
    }
    
    var enableTimeSensitiveNotifications: Bool = true {
        didSet {
            defaults.set(enableTimeSensitiveNotifications, forKey: Keys.enableTimeSensitiveNotifications)
        }
    }
    
    var hasLaunchedBefore: Bool {
        get {
            guard !UserDefaults.standard.bool(forKey: "SBSimulateFirstLaunch") else { return false }
            
            return defaults.bool(forKey: #function)
        }
        set { defaults.set(newValue, forKey: #function) }
    }

    private(set) var isLaunchAtLoginEnabled: Bool

    func refreshLaunchAtLoginState() {
        isLaunchAtLoginEnabled = launchAtLogin.checkEnabled()
    }
    
    @discardableResult
    func setLaunchAtLoginEnabled(to enabled: Bool) -> LaunchAtLoginFailure? {
        guard enabled != isLaunchAtLoginEnabled else { return nil }

        let failure = launchAtLogin.setEnabled(enabled)
        refreshLaunchAtLoginState()
        return failure
    }

}

fileprivate final class PreviewLaunchAtLoginProvider: LaunchAtLoginProvider {
    
    var isEnabled = false
    
    func checkEnabled() -> Bool { isEnabled }
    
    func setEnabled(_ enabled: Bool) -> LaunchAtLoginFailure? {
        isEnabled = enabled
    
        return nil
    }
    
}
