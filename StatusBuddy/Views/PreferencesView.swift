//
//  PreferencesView.swift
//  StatusBuddy
//
//  Created by Guilherme Rambo on 11/02/20.
//  Copyright © 2020 Guilherme Rambo. All rights reserved.
//

import SwiftUI
import Sparkle

struct PreferencesView: View {
    @EnvironmentObject var preferences: Preferences

    var body: some View {
        MenuButton(label: Image("gear").resizable().frame(width: 16, height: 16)) {
            Button(action: toggleLaunchAtLogin, label: {
                HStack(spacing: 4) {
                    Image("checkmark")
                        .resizable()
                        .frame(width: 10, height: 10)
                        .opacity(self.preferences.launchAtLoginEnabled ? 1 : 0)
                    Text("Launch at Login")
                }.offset(x: -14, y: 0)
            })
            Button(action: checkForUpdates, label: { Text("Check for Updates") })
            Button(action: openWebsite, label: { Text("Website") })
            Button(action: openGithub, label: { Text("GitHub") })
            VStack {
                Divider()
            }
            Button(action: quit, label: { Text("Quit") })
        }
        .menuButtonStyle(BorderlessButtonMenuButtonStyle())
        .frame(width: 16, height: 16)
    }

    private func toggleLaunchAtLogin() {
        preferences.launchAtLoginEnabled.toggle()
    }

    private func checkForUpdates() {
        SUUpdater.shared()?.checkForUpdates(nil)
    }

    private func openWebsite() {
        _ = NSWorkspace.shared.open(URL(string: "https://statusbuddy.app")!)
    }

    private func openGithub() {
        _ = NSWorkspace.shared.open(URL(string: "https://github.com/insidegui/StatusBuddy")!)
    }

    private func quit() {
        NSApp.terminate(nil)
    }
}

struct PreferencesView_Previews: PreviewProvider {
    static var previews: some View {
        PreferencesView()
    }
}
