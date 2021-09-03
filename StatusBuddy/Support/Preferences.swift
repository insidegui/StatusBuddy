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

    static let didChangeNotification = Notification.Name("com.nsbrltda.StatusBuddy.PrefsChanged")

    private var appURL: URL { Bundle.main.bundleURL }

    @Published private var _launchAtLoginEnabled: Bool = false
    
    let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        
        _launchAtLoginEnabled = launchAtLoginEnabled
    }
    
    var hasLaunchedBefore: Bool {
        get {
            guard !UserDefaults.standard.bool(forKey: "SBSimulateFirstLaunch") else { return false }
            
            return defaults.bool(forKey: #function)
        }
        set { defaults.set(newValue, forKey: #function) }
    }

    var launchAtLoginEnabled: Bool {
        get {
            _launchAtLoginEnabled || SharedFileList.sessionLoginItems().containsItem(appURL)
        }
        set {
            _launchAtLoginEnabled = newValue

            if newValue {
                SharedFileList.sessionLoginItems().addItem(appURL)
            } else {
                SharedFileList.sessionLoginItems().removeItem(appURL)
            }

            didChange()
        }
    }

    private func didChange() {
        NotificationCenter.default.post(name: Self.didChangeNotification, object: self)
    }

}
