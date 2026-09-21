import AppKit
import OSLog

@MainActor public protocol StatusItemControllerDelegate: AnyObject {
    func statusItemControllerDidRequestShowPanel(_ controller: StatusItemController)
    func statusItemControllerDidRequestHidePanel(_ controller: StatusItemController, animated: Bool)
    func statusItemControllerIsPanelVisible(_ controller: StatusItemController) -> Bool

    func statusItemControllerWillShowPanel(_ controller: StatusItemController)
    func statusItemControllerWillHidePanel(_ controller: StatusItemController)
}

@MainActor public final class StatusItemController: NSObject {
    private let logger = Logger(subsystem: StatusUI.subsystemName, category: String(describing: StatusItemController.self))

    public let statusItem: NSStatusItem
    public weak let delegate: StatusItemControllerDelegate?

    public init(statusItem: NSStatusItem, delegate: StatusItemControllerDelegate?) {
        self.statusItem = statusItem
        self.delegate = delegate

        super.init()
    }

    public func configure() {
        if #available(macOS 27, *) {
            statusItem.expandedInterfaceDelegate = self
        }
    }

    private lazy var escapeKeyMonitor = ManagedEventMonitor(mask: [.keyDown], scope: .local)
    private lazy var clickAwayMonitor = ManagedEventMonitor(mask: [.leftMouseDown, .rightMouseDown, .otherMouseDown], scope: .global)

    // MARK: - Events

    private func activateEventMonitors() {
        logger.trace(#function)

        activateClickAwayEventMonitor()
        activateEscapeEventMonitor()
    }

    private func invalidateEventMonitors() {
        logger.trace(#function)

        clickAwayMonitor.invalidate()

        /// Escape monitor is only enabled in versions before macOS 27.
        if #unavailable(macOS 27) {
            escapeKeyMonitor.invalidate()
        }
    }

    private func activateEscapeEventMonitor() {
        /// Escape key to close is automatic in macOS 27+ when using expanded interface session.
        guard #unavailable(macOS 27) else { return }

        escapeKeyMonitor.activate()

        escapeKeyMonitor.add { [weak self] (event) -> Bool in
            switch event.type {
            case .keyDown:
                if event.keyCode == 53 {
                    self?.logger.debug("Escape key pressed")
                    self?.internalHidePanel()
                    return false
                } else {
                    return true
                }
            default:
                return true
            }
        }
    }

    private func activateClickAwayEventMonitor() {
        clickAwayMonitor.activate()

        clickAwayMonitor.add { [weak self] (event) -> Bool in
            self?.logger.debug("Clicked away with event type \(event.type.rawValue)")
            self?.internalHidePanel()
            return true
        }
    }

    // MARK: - Panel Visibility

    private var isPanelVisible: Bool { delegate?.statusItemControllerIsPanelVisible(self) == true }

    public func togglePanel() {
        let isVisible = isPanelVisible
        logger.trace("Toggle panel (isPanelVisible = \(isVisible, privacy: .public))")

        if isVisible {
            hidePanel()
        } else {
            showPanel()
        }
    }

    public func showPanel() {
        logger.trace("Show panel")

        requestShowPanel()
    }

    public func hidePanel(animated: Bool = true) {
        logger.trace("Hide panel")

        internalHidePanel(animated: animated)
    }

    private func requestShowPanel() {
        logger.trace(#function)

        activateEventMonitors()

        delegate?.statusItemControllerWillShowPanel(self)

        delegate?.statusItemControllerDidRequestShowPanel(self)
    }

    private func requestHidePanel(animated: Bool) {
        logger.trace(#function)

        delegate?.statusItemControllerWillHidePanel(self)

        delegate?.statusItemControllerDidRequestHidePanel(self, animated: animated)

        invalidateEventMonitors()
    }

    private func internalHidePanel(animated: Bool = true) {
        if #available(macOS 27, *), let expandedInterfaceSession {
            logger.trace("\(#function, privacy: .public) requesting cancellation of expanded interface session")

            /// Cancelling the expanded interface session takes care of invoking `requestHidePanel` via the delegate callback.
            expandedInterfaceSession.cancel()
        } else {
            logger.trace("\(#function, privacy: .public) using legacy route")
            requestHidePanel(animated: animated)
        }
    }

    // MARK: - Expanded Interface Session

    private var _expandedInterfaceSession: Any?
    @available(macOS 27, *)
    private var expandedInterfaceSession: NSStatusItemExpandedInterfaceSession? {
        get { _expandedInterfaceSession as? NSStatusItemExpandedInterfaceSession }
        set {
            _expandedInterfaceSession = newValue
            logger.trace("expandedInterfaceSession = \(newValue?.description ?? "<nil>", privacy: .public)")
        }
    }
}

@available(macOS 27, *)
@MainActor extension StatusItemController: @MainActor NSStatusItemExpandedInterfaceDelegate {
    public func statusItem(_ statusItem: NSStatusItem, didBegin expandedInterfaceSession: NSStatusItemExpandedInterfaceSession) {
        logger.trace("Did begin expanded interface session: \(expandedInterfaceSession, privacy: .public)")

        self.expandedInterfaceSession = expandedInterfaceSession

        requestShowPanel()
    }

    public func statusItemDidEndExpandedInterfaceSession(_ statusItem: NSStatusItem, animated: Bool) {
        logger.trace("Did end expanded interface session (animated = \(animated, privacy: .public); current session = \(self.expandedInterfaceSession?.description ?? "<nil>", privacy: .public))")

        self.expandedInterfaceSession = nil

        requestHidePanel(animated: animated)
    }
}
