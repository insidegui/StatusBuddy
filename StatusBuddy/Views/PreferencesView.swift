//
//  PreferencesView.swift
//  StatusBuddy
//
//  Created by Guilherme Rambo on 21/12/21.
//  Copyright © 2021 Guilherme Rambo. All rights reserved.
//

import SwiftUI

struct PreferencesView: View {
    @EnvironmentObject var preferences: Preferences
    @EnvironmentObject var updateController: UpdateController
    
    @Environment(\.closeWindow) var closeWindow
    
    var body: some View {
        Form {
            VStack(alignment: .leading, spacing: 12) {
                Toggle("Launch StatusBuddy at login", isOn: .init(get: {
                    preferences.isLaunchAtLoginEnabled
                }, set: { isEnabled in
                    preferences.setLaunchAtLoginEnabled(to: isEnabled)
                }))
                
                VStack(alignment: .leading) {
                    Toggle("Use time sensitive notifications", isOn: .init(get: {
                        preferences.enableTimeSensitiveNotifications
                    }, set: { isEnabled in
                        preferences.enableTimeSensitiveNotifications = isEnabled
                    }))
                    
                    Text("StatusBuddy will use time sensitive notifications to alert you when a system comes back online.")
                        .font(.callout)
                        .foregroundColor(.secondary)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.bottom, 6)
                        .frame(maxHeight: 50, alignment: .topLeading)
                }

                if updateController.isAvailable {
                    VStack(alignment: .leading) {
                        Toggle("Check for updates automatically", isOn: $updateController.automaticallyCheckForUpdates)

                        Button("Check Now") {
                            updateController.checkForUpdates()
                        }
                    }
                }
            }
            
            HStack {
                Spacer()
                
                Button("Done") {
                    closeWindow()
                }
                .keyboardShortcut(.defaultAction)
            }
            .padding(.top)
        }
        .frame(maxWidth: 320)
        .windowTitle("StatusBuddy Preferences")
    }
}

struct PreferencesView_Previews: PreviewProvider {
    static var previews: some View {
        PreferencesView()
            .padding()
            .environmentObject(Preferences.forPreviews)
            .environmentObject(UpdateController())
    }
}
