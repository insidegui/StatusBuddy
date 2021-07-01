//
//  UpdateController.swift
//  StatusBuddy
//
//  Created by Guilherme Rambo on 01/07/21.
//  Copyright © 2021 Guilherme Rambo. All rights reserved.
//

import Foundation

#if ENABLE_SPARKLE
import Sparkle
import AppKit
#endif

final class UpdateController: ObservableObject {
    
    #if ENABLE_SPARKLE
    var updater: SPUUpdater?
    #endif
    
    func checkForUpdates() {
        #if ENABLE_SPARKLE
        updater?.checkForUpdates()
        #else
        let alert = NSAlert()
        alert.messageText = "Updates Not Supported"
        alert.informativeText = "This build doesn't support automatic updates."
        alert.addButton(withTitle: "OK")
        alert.runModal()
        #endif
    }
    
}
