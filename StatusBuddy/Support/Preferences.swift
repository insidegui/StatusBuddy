//
//  Preferences.swift
//  StatusBuddy
//
//  Created by Guilherme Rambo on 11/02/20.
//  Copyright © 2020 Guilherme Rambo. All rights reserved.
//

import Foundation
import Combine

final class Preferences: ObservableObject {

    private var appURL: URL { Bundle.main.bundleURL }

    let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults

    }
    
    var hasLaunchedBefore: Bool {
        get {
            guard !UserDefaults.standard.bool(forKey: "SBSimulateFirstLaunch") else { return false }
            
            return defaults.bool(forKey: #function)
        }
        set { defaults.set(newValue, forKey: #function) }
    }
    
    private let launchAtLogin = LaunchAtLoginHelper()

    var isLaunchAtLoginEnabled: Bool { launchAtLogin.checkEnabled() }
    
    func setLaunchAtLoginEnabled(to enabled: Bool) -> LaunchAtLoginHelper.Failure? {
        if enabled {
            guard !isLaunchAtLoginEnabled else { return nil }
            
            objectWillChange.send()
            
            return launchAtLogin.setEnabled(true)
        } else {
            guard isLaunchAtLoginEnabled else { return nil }
            
            objectWillChange.send()
            
            return launchAtLogin.setEnabled(false)
        }
    }

}
