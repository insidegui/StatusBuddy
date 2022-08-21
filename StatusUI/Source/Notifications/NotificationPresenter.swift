//
//  NotificationPresenter.swift
//  NotificationPresenter
//
//  Created by Guilherme Rambo on 21/07/21.
//  Copyright © 2021 Guilherme Rambo. All rights reserved.
//

import Foundation
import UserNotifications
import os.log

public struct ServiceRestoredNotification: Identifiable, Hashable {
    public let id: String
    public let serviceName: String
}

public protocol NotificationPresenter: AnyObject {
    var enableTimeSensitiveNotifications: Bool { get set }
    func present(_ notification: ServiceRestoredNotification)
    func requestNotificationPermissionIfNeeded()
}

public final class DefaultNotificationPresenter: NSObject, NotificationPresenter, UNUserNotificationCenterDelegate {
    
    private let log = OSLog(subsystem: StatusUI.subsystemName, category: String(describing: DefaultNotificationPresenter.self))
    
    public var enableTimeSensitiveNotifications: Bool = false
    
    public override init() {
        super.init()
        
        UNUserNotificationCenter.current().delegate = self
    }
    
    public func present(_ notification: ServiceRestoredNotification) {
        let content = UNMutableNotificationContent()
        content.title = notification.serviceName
        content.body = "This service's issues are now resolved."

        if #available(macOS 12.0, *), enableTimeSensitiveNotifications {
            content.interruptionLevel = .timeSensitive
        }
        
        let request = UNNotificationRequest(identifier: notification.id, content: content, trigger: nil)
        
        UNUserNotificationCenter.current().add(request) { [weak self] error in
            guard let self = self else { return }
            
            if let error = error {
                os_log("Failed to request notification presentation: %{public}@", log: self.log, type: .error, String(describing: error))
            }
        }
    }
    
    public func requestNotificationPermissionIfNeeded() {
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            guard let self = self else { return }
            
            if settings.authorizationStatus != .authorized { self.requestPermission() }
        }
    }
    
    private func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.sound, .alert]) { [weak self] result, error in
            guard let self = self else { return }
            
            if let error = error {
                os_log("Error requesting notification authorization: %{public}@", log: self.log, type: .debug, String(describing: error))
            } else {
                os_log("Notification authorization status = %{public}@", log: self.log, type: .debug, String(describing: result))
            }
        }
    }
    
    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler(.banner)
    }
    
}
