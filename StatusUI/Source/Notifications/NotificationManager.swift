//
//  NotificationManager.swift
//  NotificationManager
//
//  Created by Guilherme Rambo on 21/07/21.
//  Copyright © 2021 Guilherme Rambo. All rights reserved.
//

import Foundation
import StatusCore
import Combine
import os.log

public final class NotificationManager: ObservableObject {
    
    public struct Registration: Identifiable, Hashable {
        public var id: String { serviceName }
        let scope: ServiceScope
        let serviceName: String
    }
    
    private let log = OSLog(subsystem: StatusUI.subsystemName, category: String(describing: NotificationManager.self))
    
    private lazy var cancellables = Set<AnyCancellable>()

    @Published public var latestResponses: [ServiceScope: StatusResponse] = [:]
    
    @Published public private(set) var registrations: [Registration] = []
    
    public let presenter: NotificationPresenter
    
    public init(with presenter: NotificationPresenter = DefaultNotificationPresenter()) {
        self.presenter = presenter
        
        $latestResponses.sink { [weak self] newResponses in
            guard let self = self else { return }
            self.processUpdatedResponses(newResponses, oldValue: self.latestResponses)
        }.store(in: &cancellables)
    }
    
    public func hasNotificationsEnabled(for serviceName: String, in scope: ServiceScope) -> Bool {
        registrations.contains(where: { $0.scope == scope && $0.serviceName == serviceName })
    }
    
    public func toggleNotificationsEnabled(for serviceName: String, in scope: ServiceScope) {
        presenter.requestNotificationPermissionIfNeeded()
        
        if let registrationIndex = registrations.firstIndex(where: { $0.serviceName == serviceName && $0.scope == scope }) {
            registrations.remove(at: registrationIndex)
            
            os_log("Removed notification registration for %{public}@", log: self.log, type: .debug, serviceName)
        } else {
            let newRegistration = Registration(scope: scope, serviceName: serviceName)
            registrations.append(newRegistration)
            
            os_log("Created notification registration for %{public}@", log: self.log, type: .debug, serviceName)
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
        os_log("%{public}@", log: log, type: .debug, #function)
        
        guard responses != oldValue else {
            os_log("Ignoring update because there's been no change", log: self.log, type: .debug)
            return
        }
        
        let oldStates = servicesPendingNotification(in: oldValue)
        let newStates = servicesPendingNotification(in: responses)
        
        let notifications: [ServiceRestoredNotification] = newStates.compactMap { newService in
            guard let oldService = oldStates.first(where: { $0.serviceName == newService.serviceName }) else { return nil }
            
            guard oldService.hasActiveEvents, !newService.hasActiveEvents else { return nil }
            
            return ServiceRestoredNotification(id: newService.serviceName, serviceName: newService.serviceName)
        }
        
        guard !notifications.isEmpty else { return }
        
        os_log("Produced %{public}d service restored notification(s)", log: self.log, type: .debug, notifications.count)
        
        notifications.forEach { notification in
            presenter.present(notification)
            
            if let registrationIndex = registrations.firstIndex(where: { $0.serviceName == notification.serviceName }) {
                registrations.remove(at: registrationIndex)
            }
        }
    }
    
}
