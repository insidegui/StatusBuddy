import AppKit

/// An event monitor that manages monitor lifecycles and monitors both locally and globally.
@MainActor
final class ManagedEventMonitor {
    nonisolated struct Scope: OptionSet, Hashable, CustomStringConvertible {
        let rawValue: Int

        static let local = Scope(rawValue: 1 << 0)
        static let global = Scope(rawValue: 1 << 1)

        static let all: Scope = [.local, .global]

        var description: String {
            var components = [String]()
            if contains(.local) {
                components.append("local")
            }
            if contains(.global) {
                components.append("global")
            }
            return components.formatted(.list(type: .and))
        }
    }

    let mask: NSEvent.EventTypeMask
    let scope: Scope

    init(mask: NSEvent.EventTypeMask, scope: Scope = .all) {
        self.mask = mask
        self.scope = scope
    }

    /// A receiver that only cares about receiving events and does not wish to filter local events.
    typealias EventReceiver = (_ event: NSEvent) -> ()

    /// A receiver that may also block local event propagation by returning `false`.
    typealias FilteringEventReceiver = (_ event: NSEvent) -> Bool

    private lazy var receivers = [EventReceiver]()
    private lazy var filteringReceivers = [FilteringEventReceiver]()
    private lazy var scopedReceivers = [Scope: [EventReceiver]]()

    private lazy var monitors = [Any]()

    private var activated = false

    func add(_ receiver: @escaping EventReceiver) {
        receivers.append(receiver)
    }

    func add(_ receiver: @escaping FilteringEventReceiver) {
        filteringReceivers.append(receiver)
    }

    func add(_ receiver: @escaping EventReceiver, on scope: Scope) {
        scopedReceivers[scope, default: []].append(receiver)
    }

    func activate() {
        guard !activated else { return }
        activated = true

        if scope.contains(.local) {
            if let localMonitor = NSEvent.addLocalMonitorForEvents(matching: mask, handler: { [weak self] event in
                guard let self else { return event }
                let result = receivedEvent(event, scope: .local)
                return result ? event : nil
            }) {
                monitors.append(localMonitor)
            }
        }
        if scope.contains(.global) {
            if let globalMonitor = NSEvent.addGlobalMonitorForEvents(matching: mask, handler: { [weak self] event in
                self?.receivedEvent(event, scope: .global)
            }) {
                monitors.append(globalMonitor)
            }
        }
    }

    func invalidate() {
        guard activated else { return }
        activated = false

        for monitor in monitors {
            NSEvent.removeMonitor(monitor)
        }
        monitors.removeAll()

        receivers.removeAll()
        filteringReceivers.removeAll()
        scopedReceivers.removeAll()
    }

    @discardableResult
    private func receivedEvent(_ event: NSEvent, scope: Scope) -> Bool {
        scopedReceivers[scope]?.forEach { $0(event) }
        receivers.forEach { $0(event) }

        if filteringReceivers.isEmpty {
            return true
        } else {
            /// Block event propagation if any filtering receiver returns `false`.
            let result = filteringReceivers.reduce(true, { $0 && $1(event) })
            return result
        }
    }

    @MainActor deinit {
        invalidate()
    }
}
