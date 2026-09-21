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
        guard #available(macOS 27, *) else { return }

        statusItem.expandedInterfaceDelegate = self
    }

    private var isPanelVisible: Bool { delegate?.statusItemControllerIsPanelVisible(self) == true }

    private var _expandedInterfaceSession: Any?
    @available(macOS 27, *)
    private var expandedInterfaceSession: NSStatusItemExpandedInterfaceSession? {
        get { _expandedInterfaceSession as? NSStatusItemExpandedInterfaceSession }
        set {
            _expandedInterfaceSession = newValue
            logger.trace("expandedInterfaceSession = \(newValue?.description ?? "<nil>", privacy: .public)")
        }
    }

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

        requestHidePanel(animated: animated)
    }

    private func requestShowPanel() {
        logger.trace(#function)

        delegate?.statusItemControllerWillShowPanel(self)

        delegate?.statusItemControllerDidRequestShowPanel(self)
    }

    private func requestHidePanel(animated: Bool) {
        logger.trace(#function)

        delegate?.statusItemControllerWillHidePanel(self)

        delegate?.statusItemControllerDidRequestHidePanel(self, animated: animated)
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
