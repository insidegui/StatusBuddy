//
//  LaunchAtLoginHelper.swift
//  StatusBuddy
//
//  Created by Guilherme Rambo on 21/12/21.
//  Copyright © 2021 Guilherme Rambo. All rights reserved.
//

import Cocoa
import ServiceManagement

final class LaunchAtLoginHelper {
    
    static let helperAppIdentifier = "tech.buddysoftware.StatusBuddyHelper"
    
    struct Failure: LocalizedError {
        var errorDescription: String?
        
        static let enable = Failure(errorDescription: "Sorry, enabling launch at login failed. Make sure that you don't have multiple copies of the app on your Mac.")
        static let disable = Failure(errorDescription: "Sorry, disabling launch at login failed. Make sure that you don't have multiple copies of the app on your Mac.")
    }
    
    func checkEnabled() -> Bool {
        // Not actually deprecated according to the headers.
        guard let jobDictsPtr = SMCopyAllJobDictionaries(kSMDomainUserLaunchd) else { return false }
        
        guard let dicts = jobDictsPtr.takeUnretainedValue() as? [[String: Any]] else { return false }
        
        return dicts.contains(where: { $0["Label"] as? String == Self.helperAppIdentifier })
    }
    
    func setEnabled(_ enabled: Bool) -> Failure? {
        #if DEBUG
        guard !UserDefaults.standard.bool(forKey: "SBSimulateLaunchAtLoginEnablementError") else {
            return .enable
        }
        #endif
        
        if enabled {
            return SMLoginItemSetEnabled(Self.helperAppIdentifier as CFString, true) ? nil : .enable
        } else {
            return SMLoginItemSetEnabled(Self.helperAppIdentifier as CFString, false) ? nil : .disable
        }
    }
    
}
