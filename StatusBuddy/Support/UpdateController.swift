//
//  UpdateController.swift
//  StatusBuddy
//
//  Created by Guilherme Rambo on 01/07/21.
//  Copyright © 2021 Guilherme Rambo. All rights reserved.
//

import Cocoa

#if ENABLE_SPARKLE
import Sparkle
#endif

final class UpdateController: NSObject, ObservableObject {

    var isAvailable: Bool {
        #if ENABLE_SPARKLE
        return true
        #else
        return false
        #endif
    }
    
    #if ENABLE_SPARKLE
    private lazy var controller: SPUStandardUpdaterController = {
        SPUStandardUpdaterController(
            startingUpdater: false,
            updaterDelegate: self,
            userDriverDelegate: self
        )
    }()
    #endif

    @Published var automaticallyCheckForUpdates = false {
        didSet {
            #if ENABLE_SPARKLE
            controller.updater.automaticallyChecksForUpdates = automaticallyCheckForUpdates
            #endif
        }
    }

    func activate() {
        #if ENABLE_SPARKLE
        controller.startUpdater()
        automaticallyCheckForUpdates = controller.updater.automaticallyChecksForUpdates
        #endif
    }
    
    func checkForUpdates() {
        #if ENABLE_SPARKLE
        controller.checkForUpdates(nil)
        #else
        let alert = NSAlert()
        alert.messageText = "Updates Not Supported"
        alert.informativeText = "This build doesn't support automatic updates."
        alert.addButton(withTitle: "OK")
        alert.runModal()
        #endif
    }
    
}

#if ENABLE_SPARKLE
extension UpdateController: SPUUpdaterDelegate, SPUStandardUserDriverDelegate {

}
#endif
