import AppKit
import OSLog

/// Base class for all application-level assertions.
@MainActor
public class AppAssertion: NSObject {
    fileprivate let invalidationHandler: (_ assertion: AppAssertion) -> ()

    fileprivate let id: NSUUID

    required init(invalidationHandler: @escaping (_ assertion: AppAssertion) -> Void) {
        self.id = NSUUID()
        self.invalidationHandler = invalidationHandler

        super.init()
    }

    /// Called when the first assertion of this type is created.
    func activated() {
    }

    /// Called when the last assertion of this type is invalidated.
    func invalidated() {
    }

    deinit { invalidationHandler(self) }

    public override var description: String { id.uuidString }
}

// MARK: - Menu Bar Visibility

/// Maintains the menu bar visible and locked for the lifetime of the object.
@MainActor
public final class MenuBarVisibilityAssertion: AppAssertion {
    override func activated() {
        DistributedNotificationCenter.default().post(name: .init("com.apple.HIToolbox.beginMenuTrackingNotification"), object: nil)
    }

    override func invalidated() {
        DistributedNotificationCenter.default().post(name: .init("com.apple.HIToolbox.endMenuTrackingNotification"), object: nil)
    }
}

@MainActor
public extension NSApplication {
    func requestMenuBarVisible() -> MenuBarVisibilityAssertion {
        activationAssertionManager.add(MenuBarVisibilityAssertion.self)
    }
}

// MARK: - App Activation Policy

/// Maintains the app's regular activation policy for the lifetime of the object.
@MainActor
public final class AppActivationPolicyAssertion: AppAssertion {
    override func activated() {
        NSApplication.shared.setActivationPolicy(.regular)
        DispatchQueue.main.async {
            NSApp.activate()
        }
    }

    override func invalidated() {
        NSApplication.shared.setActivationPolicy(.accessory)
    }
}

@MainActor
public extension NSApplication {
    func requestRegularActivationPolicy() -> AppActivationPolicyAssertion {
        activationAssertionManager.add(AppActivationPolicyAssertion.self)
    }
}

// MARK: - Manager

@MainActor
private extension NSApplication {
    private var activationAssertionManager: ActivationAssertionManager { .shared }

    @MainActor
    final class ActivationAssertionManager {
        static let shared = ActivationAssertionManager()

        private let logger = Logger(subsystem: StatusUI.subsystemName, category: String(describing: ActivationAssertionManager.self))

        private let assertions = NSMapTable<NSUUID, AppAssertion>(keyOptions: [.objectPersonality], valueOptions: [.weakMemory])

        func add<A>(_ type: A.Type) -> A where A: AppAssertion {
            let assertion = A.init { assertion in
                self.handleInvalidated(assertion)
            }
            let activate = assertions.count == 0

            assertions.setObject(assertion, forKey: assertion.id)

            guard activate else { return assertion }

            logger.debug("First assertion added")

            assertion.activated()

            return assertion
        }

        func remove<A>(_ assertion: A) where A: AppAssertion {
            logger.trace("Remove \(assertion, privacy: .public)")

            assertions.removeObject(forKey: assertion.id)

            guard assertions.count == 0 else { return }

            logger.debug("Last assertion removed")

            assertion.invalidated()
        }

        func handleInvalidated<A>(_ assertion: A) where A: AppAssertion {
            logger.debug("Invalidated: \(assertion)")

            remove(assertion)
        }
    }

}
