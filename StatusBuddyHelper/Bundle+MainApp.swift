//
//  Bundle+MainApp.swift
//  StatusBuddyHelper
//
//  Created by Guilherme Rambo on 21/12/21.
//  Copyright © 2021 Guilherme Rambo. All rights reserved.
//

import Foundation

extension Bundle {
    
    /// Returns the URL for the app's main bundle.
    public var mainAppBundleURL: URL {
        #if DEBUG
        guard !Bundle.main.bundleURL.path.contains("DerivedData") else {
            return derivedDataMainAppBundleURL
        }
        #endif
        
        return bundledMainAppBundleURL
    }
    
    /// Returns `true` if the app is running from within the Xcode DerivedData folder.
    /// Always returns `false` in release builds.
    /// Assumes the path for the folder contains `DerivedData`.
    public var isInDerivedDataFolder: Bool {
        #if DEBUG
        return bundlePath.contains("DerivedData")
        #else
        return false
        #endif
    }
    
    private var bundledMainAppBundleURL: URL {
        return bundleURL
            .deletingLastPathComponent() // StatusBuddyHelper.app
            .deletingLastPathComponent() // LoginItems
            .deletingLastPathComponent() // Library
            .deletingLastPathComponent() // Contents
    }
    
    #if DEBUG
    /// Handles StatusBuddyHelper running directly from within Xcode, in which case it
    /// will be outside of the main app bundle.
    private var derivedDataMainAppBundleURL: URL {
        let mainAppURL = Bundle.main.bundleURL
            .deletingLastPathComponent()
            .appendingPathComponent("StatusBuddy.app")
        
        guard FileManager.default.fileExists(atPath: mainAppURL.path) else {
            return bundledMainAppBundleURL
        }
        
        return mainAppURL
    }
    #endif
    
}
