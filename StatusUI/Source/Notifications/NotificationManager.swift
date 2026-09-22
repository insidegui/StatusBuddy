//
//  NotificationManager.swift
//  NotificationManager
//
//  Created by Guilherme Rambo on 21/07/21.
//  Copyright © 2021 Guilherme Rambo. All rights reserved.
//

import Foundation
import StatusCore
import Observation
import OSLog

@MainActor
@Observable
public final class NotificationManager {
    
    public struct Registration: Identifiable, Hashable {
        public var id: String { serviceName }
        let scope: ServiceScope
        let serviceName: String
    }
    
    private let logger = Logger(subsystem: StatusUI.subsystemName, category: String(describing: NotificationManager.self))
    
    public var latestResponses: [ServiceScope: StatusResponse] = [:] {
        didSet { processUpdatedResponses(latestResponses, oldValue: oldValue) }
    }
    
    public private(set) var registrations: [Registration] = []
    
    public let presenter: NotificationPresenter
    
    public init(with presenter: NotificationPresenter = DefaultNotificationPresenter()) {
        self.presenter = presenter
    }
    
    public func hasNotificationsEnabled(for serviceName: String, in scope: ServiceScope) -> Bool {
        registrations.contains(where: { $0.scope == scope && $0.serviceName == serviceName })
    }
    
    public func toggleNotificationsEnabled(for serviceName: String, in scope: ServiceScope) {
        presenter.requestNotificationPermissionIfNeeded()
        
        if let registrationIndex = registrations.firstIndex(where: { $0.serviceName == serviceName && $0.scope == scope }) {
            registrations.remove(at: registrationIndex)
            
            logger.debug("Removed notification registration for \(serviceName, privacy: .public)")
        } else {
            let newRegistration = Registration(scope: scope, serviceName: serviceName)
            registrations.append(newRegistration)
            
            logger.debug("Created notification registration for \(serviceName, privacy: .public)")
        }
    }
    
    private func servicesPendingNotification(in responses: [ServiceScope: StatusResponse]) -> [Service] {
        responses.compactMap { scope, response -> [Service]? in
            guard registrations.contains(where: { $0.scope == scope }) else { return nil }
            return response.services.filter { service in
                registrations.contains(where: { $0.serviceName == service.serviceName })
            }
        }.flatMap({ $0 })
    }
    
    private func processUpdatedResponses(_ responses: [ServiceScope: StatusResponse], oldValue: [ServiceScope: StatusResponse]) {
        logger.debug("\(#function, privacy: .public)")

        let oldStates = servicesPendingNotification(in: oldValue)
        let newStates = servicesPendingNotification(in: responses)
        
        let notifications: [ServiceRestoredNotification] = newStates.compactMap { newService in
            guard let oldService = oldStates.first(where: { $0.serviceName == newService.serviceName }) else { return nil }
            
            guard oldService.hasActiveEvents, !newService.hasActiveEvents else { return nil }
            
            return ServiceRestoredNotification(id: newService.serviceName, serviceName: newService.serviceName)
        }
        
        guard !notifications.isEmpty else { return }
        
        logger.debug("Produced \(notifications.count) service restored notification(s)")
        
        notifications.forEach { notification in
            presenter.present(notification)
            
            if let registrationIndex = registrations.firstIndex(where: { $0.serviceName == notification.serviceName }) {
                registrations.remove(at: registrationIndex)
            }
        }
    }
    
}
