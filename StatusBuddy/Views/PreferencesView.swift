//
//  PreferencesView.swift
//  StatusBuddy
//
//  Created by Guilherme Rambo on 21/12/21.
//  Copyright © 2021 Guilherme Rambo. All rights reserved.
//

import SwiftUI

struct PreferencesView: View {
    @Environment(Preferences.self) private var preferences
    @Environment(UpdateController.self) private var updateController
    
    @Environment(\.closeWindow) var closeWindow

    @State private var launchAtLoginFailure: LaunchAtLoginFailure?
    @State private var isShowingLaunchAtLoginFailure = false

    var body: some View {
        @Bindable var updateController = updateController

        VStack(spacing: 0) {
            Form {
                Section {
                    Toggle("Launch StatusBuddy at login", isOn: .init(get: {
                        preferences.isLaunchAtLoginEnabled
                    }, set: { isEnabled in
                        if let failure = preferences.setLaunchAtLoginEnabled(to: isEnabled) {
                            launchAtLoginFailure = failure
                            isShowingLaunchAtLoginFailure = true
                        }
                    }))
                }

                Section {
                    Toggle("Use time sensitive notifications", isOn: .init(get: {
                        preferences.enableTimeSensitiveNotifications
                    }, set: { isEnabled in
                        preferences.enableTimeSensitiveNotifications = isEnabled
                    }))
                    
                    Text("StatusBuddy will use time sensitive notifications to alert you when a system comes back online.")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                }

                if updateController.isAvailable {
                    Section {
                        Toggle("Check for updates automatically", isOn: $updateController.automaticallyCheckForUpdates)

                        Button("Check Now") {
                            updateController.checkForUpdates()
                        }
                    }
                }
            }
            .formStyle(.grouped)

            HStack {
                Spacer()
                
                Button("Done") {
                    closeWindow()
                }
                .keyboardShortcut(.defaultAction)
            }
            .padding([.horizontal, .bottom])
        }
        .frame(width: 420, height: updateController.isAvailable ? 380 : 290)
        .windowTitle("StatusBuddy Preferences")
        .onAppear { preferences.refreshLaunchAtLoginState() }
        .alert("Launch at Login", isPresented: $isShowingLaunchAtLoginFailure, presenting: launchAtLoginFailure) { _ in
            Button("System Settings") {
                LaunchAtLoginHelper.openSystemSettings()
            }
            Button("Dismiss", role: .cancel) { }
        } message: { failure in
            Text(failure.localizedDescription)
        }
    }
}

struct PreferencesView_Previews: PreviewProvider {
    static var previews: some View {
        PreferencesView()
            .environment(Preferences.forPreviews)
            .environment(UpdateController())
    }
}
