import AppKit
import OSLog

@MainActor public protocol StatusItemControllerDelegate: AnyObject {
    func statusItemControllerDidRequestShowPanel(_ controller: StatusItemController)
    func statusItemControllerDidRequestHidePanel(_ controller: StatusItemController, animated: Bool)
    func statusItemControllerIsPanelVisible(_ controller: StatusItemController) -> Bool

    func statusItemControllerWillShowPanel(_ controller: StatusItemController)
    func statusItemControllerWillHidePanel(_ controller: StatusItemController)

    func statusItemControllerShouldHidePanelInResponseToStatusItemClick(_ controller: StatusItemController) -> Bool
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
            guard let self else { return true }

            logger.trace("Clicked away with event type \(event.type.rawValue)")

            guard clickAwayShouldDelegatePanelHideDecision(with: event) else {
                logger.trace("Click away determined event should hide panel")

                internalHidePanel()

                return true
            }

            guard let delegate else {
                logger.trace("Click away determined event should delegate hide panel decision, but no delegate available, hiding")

                internalHidePanel()

                return true
            }

            logger.trace("Click away determined event should delegate hide panel decision")

            guard delegate.statusItemControllerShouldHidePanelInResponseToStatusItemClick(self) else {
                logger.trace("Delegate decided click away should NOT hide panel")

                /// Stop click event propagation.
                return false
            }

            logger.trace("Delegate decided click away should hide panel")

            internalHidePanel()

            return true
        }
    }

    private func clickAwayShouldDelegatePanelHideDecision(with event: NSEvent) -> Bool {
        logger.trace("\(#function, privacy: .public) locationInWindow = \(String(describing: event.locationInWindow))")

        guard let view = statusItem.button ?? statusItem.view else {
            logger.fault("NSStatusItem has no button nor view we can use as a reference for click-away handling!")
            assertionFailure("NSStatusItem has no button nor view we can use as a reference for click-away handling!")
            return true
        }
        guard let itemWindow = view.window, let contentView = itemWindow.contentView else {
            logger.fault("NSStatusItem view has no window we can use as a reference for click-away handling!")
            assertionFailure("NSStatusItem view has no window we can use as a reference for click-away handling!")
            return true
        }

        let locationOnScreen: CGPoint = if let eventWindow = event.window {
            eventWindow.convertPoint(toScreen: event.locationInWindow)
        } else {
            event.locationInWindow
        }
        let hitView = contentView.hitTest(contentView.convert(itemWindow.convertPoint(fromScreen: locationOnScreen), from: nil))

        logger.trace("\(#function, privacy: .public) locationOnScreen = \(String(describing: locationOnScreen)); hitView = \(hitView?.description ?? "<nil>")")

        /// Only hide panel automatically as a response to a "click outside" if the "click outside" is not actually a click within the status item itself,
        /// in which case the decision as to whether to close will be delegated.
        return hitView != nil
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

        guard #available(macOS 27, *) else {
            requestShowPanel()
            return
        }

        if statusItem.sb_startExpandedInterfaceSession() {
            logger.trace("\(#function, privacy: .public) start expanded interface session worked")
        } else {
            logger.trace("\(#function, privacy: .public) start expanded interface session failed, falling back to manual presentation")
            requestShowPanel()
        }
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
