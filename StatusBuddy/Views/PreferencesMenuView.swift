//
//  PreferencesMenuView.swift
//  StatusBuddy
//
//  Created by Guilherme Rambo on 11/02/20.
//  Copyright © 2020 Guilherme Rambo. All rights reserved.
//

import SwiftUI
import Combine
import StatusCore
import StatusUI

struct PreferencesMenuView: View {
    let refresh: PassthroughSubject<Void, Never>
    
    @EnvironmentObject var viewModel: RootViewModel
    @EnvironmentObject var preferences: Preferences
    @EnvironmentObject var updateController: UpdateController

    var body: some View {
        MenuButton(label: Image("gear").resizable().frame(width: 16, height: 16)) {
            Button(action: refresh.send, label: { Text("Refresh") })
            Button(action: toggleLaunchAtLogin, label: {
                HStack(spacing: 4) {
                    if preferences.launchAtLoginEnabled {
                        Image("checkmark")
                    }
                    Text("Launch at Login")
                }.offset(x: -14, y: 0)
            })

            VStack { Divider() }

            Button(action: checkForUpdates, label: { Text("Check for Updates") })
            Button(action: openWebsite, label: { Text("Website") })
            Button(action: openGithub, label: { Text("GitHub") })

            VStack { Divider() }

            Button(action: quit, label: { Text("Quit") })
        }
        .menuButtonStyle(BorderlessButtonMenuButtonStyle())
        .frame(width: 16, height: 16)
    }

    private func toggleLaunchAtLogin() {
        preferences.launchAtLoginEnabled.toggle()
    }

    private func checkForUpdates() {
        updateController.checkForUpdates()
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

struct PreferencesMenuView_Previews: PreviewProvider {
    static let refresh = PassthroughSubject<Void, Never>()
    static var previews: some View {
        PreferencesMenuView(refresh: refresh)
            .onReceive(refresh) { _ in
                print("REFRESH")
            }
            .environmentObject(Preferences())
    }
}
