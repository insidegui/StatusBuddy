import Foundation
import XCTest
@testable import StatusCore
@testable import StatusUI

final class NotificationManagerTests: XCTestCase {
    
    private func makeManager() -> (NotificationManager, MockNotificationPresenter) {
        let presenter = MockNotificationPresenter()
        let manager = NotificationManager(with: presenter)
        return (manager, presenter)
    }
    
    func testRegisteringNotificationRequestsForPermission() {
        let (manager, presenter) = makeManager()
        
        manager.toggleNotificationsEnabled(for: "TEST", in: .customer)
        
        XCTAssertTrue(presenter.permissionRequested)
    }
    
    func testTogglingNotificationOnAndOff() {
        let (manager, _) = makeManager()
        
        XCTAssertEqual(manager.registrations.count, 0)

        manager.toggleNotificationsEnabled(for: "TEST", in: .customer)
        
        XCTAssertEqual(manager.registrations.count, 1)
        
        manager.toggleNotificationsEnabled(for: "TEST", in: .customer)
        
        XCTAssertEqual(manager.registrations.count, 0)
    }
    
    func testOutageResolutionTriggersNotification() {
        let (manager, presenter) = makeManager()
        
        let testServiceWithIssue = Service(serviceName: "Test", redirectUrl: nil, events: [
            Service.Event(epochStartDate: Date(), epochEndDate: nil, message: "Test outage", eventStatus: "Outage")
        ])
        let testServiceWithoutIssue = Service(serviceName: "Test", redirectUrl: nil, events: [
            Service.Event(epochStartDate: .distantPast, epochEndDate: Date(), message: "Test outage (resolved)", eventStatus: "resolved")
        ])
        
        manager.toggleNotificationsEnabled(for: "Test", in: .customer)
        
        manager.latestResponses = [.customer: StatusResponse(services: [testServiceWithIssue])]
        
        XCTAssertEqual(presenter.presentedNotifications.count, 0)
        
        manager.latestResponses = [.customer: StatusResponse(services: [testServiceWithoutIssue])]
        
        XCTAssertEqual(presenter.presentedNotifications.count, 1)
    
        // Registration should be removed after delivering the notification.
        XCTAssertEqual(manager.registrations.count, 0)
    }
    
}

final class MockNotificationPresenter: NotificationPresenter {
    
    private(set) var permissionRequested = false
    private(set) var presentedNotifications: [ServiceRestoredNotification] = []
    
    func requestNotificationPermissionIfNeeded() {
        permissionRequested = true
    }

    func present(_ notification: ServiceRestoredNotification) {
        presentedNotifications.append(notification)
    }

}
