//
//  HelperAppDelegate.swift
//  StatusBuddyHelper
//
//  Created by Guilherme Rambo on 21/12/21.
//  Copyright © 2021 Guilherme Rambo. All rights reserved.
//

import Cocoa
import os.log

@main
final class HelperAppDelegate: NSObject, NSApplicationDelegate {
    
    private let log = OSLog(subsystem: "tech.buddysoftware.StatusBuddyHelper", category: String(describing: HelperAppDelegate.self))

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let config = NSWorkspace.OpenConfiguration()
        config.activates = false
        config.addsToRecentItems = false
        config.promptsUserIfNeeded = false
        
        NSWorkspace.shared.openApplication(
            at: Bundle.main.mainAppBundleURL,
            configuration: config) { _, error in
                if let error = error {
                    os_log("Failed to launch main app: %{public}@", log: self.log, type: .fault, String(describing: error))
                } else {
                    os_log("Main app launched successfully", log: self.log, type: .info)
                }
                
                DispatchQueue.main.async { NSApp?.terminate(nil) }
            }
    }

}

