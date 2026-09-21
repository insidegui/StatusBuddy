import AppKit
import OSLog

/// Maintains the app's regular activation policy for the lifetime of the object.
@MainActor
public final class ActivationPolicyAssertion: NSObject {
    fileprivate let invalidationHandler: (_ id: NSUUID) -> ()

    fileprivate let id: NSUUID

    fileprivate init(invalidationHandler: @escaping (_ id: NSUUID) -> Void) {
        self.id = NSUUID()
        self.invalidationHandler = invalidationHandler

        super.init()
    }

    deinit { invalidationHandler(id) }

    public override var description: String { id.uuidString }
}

@MainActor
public extension NSApplication {
    func requestRegularActivationPolicy() -> ActivationPolicyAssertion {
        activationAssertionManager.add()
    }
}

@MainActor
private extension NSApplication {
    private var activationAssertionManager: ActivationAssertionManager { .shared }

    @MainActor
    final class ActivationAssertionManager {
        static let shared = ActivationAssertionManager()

        private let logger = Logger(subsystem: StatusUI.subsystemName, category: String(describing: ActivationAssertionManager.self))

        private let assertions = NSMapTable<NSUUID, ActivationPolicyAssertion>(keyOptions: [.objectPersonality], valueOptions: [.weakMemory])

        func add() -> ActivationPolicyAssertion {
            let assertion = ActivationPolicyAssertion { id in
                self.handleInvalidated(id)
            }
            let applyPolicy = assertions.count == 0

            assertions.setObject(assertion, forKey: assertion.id)

            guard applyPolicy else { return assertion }

            logger.debug("First assertion added, setting regular activation policy")

            NSApplication.shared.setActivationPolicy(.regular)
            DispatchQueue.main.async {
                NSApp.activate()
            }

            return assertion
        }

        func remove(_ id: NSUUID) {
            logger.trace("Remove \(id, privacy: .public)")

            assertions.removeObject(forKey: id)

            guard assertions.count == 0 else { return }

            logger.debug("Last assertion removed, restoring accessory activation policy")

            NSApplication.shared.setActivationPolicy(.accessory)
        }

        func handleInvalidated(_ id: NSUUID) {
            logger.debug("Invalidated: \(id)")

            remove(id)
        }
    }

}
