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

    static let didChangeNotification = Notification.Name("codes.rambo.StatusBuddy.PrefsChanged")

    private var appURL: URL { Bundle.main.bundleURL }

    var launchAtLoginEnabled: Bool {
        get { SharedFileList.sessionLoginItems().containsItem(appURL) }
        set {
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
