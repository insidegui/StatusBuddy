//
//  HelperAppDelegate.swift
//  StatusBuddyHelper
//
//  Created by Guilherme Rambo on 21/12/21.
//  Copyright © 2021 Guilherme Rambo. All rights reserved.
//

import Cocoa
import OSLog

@main
final class HelperAppDelegate: NSObject, NSApplicationDelegate {
    
    private let logger = Logger(subsystem: "tech.buddysoftware.StatusBuddyHelper", category: String(describing: HelperAppDelegate.self))

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let config = NSWorkspace.OpenConfiguration()
        config.activates = false
        config.addsToRecentItems = false
        config.promptsUserIfNeeded = false
        
        NSWorkspace.shared.openApplication(
            at: Bundle.main.mainAppBundleURL,
            configuration: config) { _, error in
                if let error = error {
                    self.logger.fault("Failed to launch main app: \(String(describing: error), privacy: .public)")
                } else {
                    self.logger.info("Main app launched successfully")
                }
                
                DispatchQueue.main.async { NSApp?.terminate(nil) }
            }
    }

}

