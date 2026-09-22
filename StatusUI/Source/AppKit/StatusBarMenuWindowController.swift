//
//  StatusBarMenuWindowController.swift
//  StatusUI
//
//  Created by Gui Rambo on 04/12/20.
//

import AppKit
import OSLog

@MainActor
public final class StatusBarMenuWindowController: NSWindowController {
    
    private let logger = Logger(subsystem: StatusUI.subsystemName, category: String(describing: StatusBarMenuWindowController.self))
    
    public let statusItem: NSStatusItem?
    
    public var windowWillClose: (_ controller: StatusBarMenuWindowController) -> () = { _ in }

    let topMargin: CGFloat

    private var panel: StatusBarMenuPanel? { window as? StatusBarMenuPanel }

    public init(statusItem: NSStatusItem?, contentViewController: NSViewController, topMargin: CGFloat = 0) {
        self.statusItem = statusItem
        self.topMargin = topMargin
        
        let panel = StatusBarMenuPanel(statusItem: statusItem)
        panel.contentViewController = contentViewController

        super.init(window: panel)
        
        panel.delegate = self
        panel.isReleasedWhenClosed = false

        trackContentSize()
    }
    
    public required init?(coder: NSCoder) {
        fatalError()
    }

    /// Keeps the menu bar visible while the panel is open, only used in macOS versions before macOS 27.
    private var menuBarVisibilityAssertion: MenuBarVisibilityAssertion?

    /// Tracks show / hide requests to prevent race conditions caused by rapid repeated calls to `showWindow` and `close(animated:)`.
    private var visibilityToken: UUID?

    public override func showWindow(_ sender: Any?) {
        /// Reset token so that a racing call to `close(animated:)` doesn't actually close the window.
        visibilityToken = nil

        repositionWindow(contentSize: panel?.contentSize)

        window?.alphaValue = 1
        
        super.showWindow(sender)
    }

    public override func close() {
        assertionFailure("close() is not available, please use close(animated:)")
    }

    public func close(animated: Bool) {
        guard animated else {
            super.close()
            return
        }

        let token = UUID()
        visibilityToken = token

        NSAnimationContext.beginGrouping()
        NSAnimationContext.current.completionHandler = {
            guard self.visibilityToken == token else {
                self.logger.debug("Close cancelled by visibility token race")
                self.window?.alphaValue = 1
                return
            }

            self.visibilityToken = nil

            super.close()
        }
        window?.animator().alphaValue = 0
        NSAnimationContext.endGrouping()
    }

    // MARK: - Positioning relative to status item
    
    private struct Metrics {
        static let margin: CGFloat = 5
    }
    
    private func repositionWindow(contentSize: CGSize?) {
        guard let referenceWindow = statusItem?.button?.window, let window = window else {
            logger.debug("Couldn't find reference window for repositioning status bar menu window, centering instead")
            self.window?.center()
            return
        }

        let inputSize: CGSize = contentSize ?? contentViewController?.preferredContentSize ?? window.frame.size
        let width = inputSize.width
        let height = inputSize.height
        var x = referenceWindow.frame.origin.x + referenceWindow.frame.width / 2 - window.frame.width / 2
        
        if let screen = referenceWindow.screen {
            // If the window extrapolates the limits of the screen, reposition it.
            if (x + width) > (screen.visibleFrame.origin.x + screen.visibleFrame.width) {
                x = (screen.visibleFrame.origin.x + screen.visibleFrame.width) - width - Metrics.margin
            }
        }
        
        let rect = NSRect(
            x: x,
            y: (referenceWindow.frame.origin.y - height - Metrics.margin) + topMargin,
            width: width,
            height: height
        )
        
        window.setFrame(rect, display: false, animate: false)
    }

    // MARK: - Auto size/position based on content controller

    private func trackContentSize() {
        withObservationTracking { [weak self] in
            self?.repositionWindow(contentSize: self?.panel?.contentSize)
        } onChange: { [weak self] in
            Task { @MainActor [weak self] in
                self?.trackContentSize()
            }
        }

    }

    /// Unlocks the menu bar visibility in case it is currently locked.
    ///
    /// The app may use this to defer termination until there's been enough time for the menu bar unlock
    /// notification to be delivered to the system, preventing a situation where terminating the app in this
    /// state may result in a permanent menu bar lock.
    public func unlockMenuBar() {
        menuBarVisibilityAssertion = nil
    }

}

// MARK: - Window delegate

extension StatusBarMenuWindowController: NSWindowDelegate {
    
    public func windowWillClose(_ notification: Notification) {
        windowWillClose(self)

        /// Prevents cycles or retention of SwiftUI content/environment.
        window?.contentView = nil
    }
    
    public func windowDidBecomeKey(_ notification: Notification) {
        highlightStatusItem()

        if #unavailable(macOS 27) {
            menuBarVisibilityAssertion = NSApplication.shared.requestMenuBarVisible()
        }
    }

    public func windowDidResignKey(_ notification: Notification) {
        dimStatusItem()

        if #unavailable(macOS 27) {
            menuBarVisibilityAssertion = nil
        }
    }

}

// MARK: - Status Item Highlight

public extension StatusBarMenuWindowController {
    func highlightStatusItem() {
        guard #unavailable(macOS 27) else { return }

        cancelStatusItemHighlightStateChange()

        perform(#selector(_highlightStatusItem), with: nil, afterDelay: 0)
    }

    func dimStatusItem() {
        guard #unavailable(macOS 27) else { return }

        cancelStatusItemHighlightStateChange()

        perform(#selector(_dimStatusItem), with: nil, afterDelay: 0)
    }
}

private extension StatusBarMenuWindowController {
    func cancelStatusItemHighlightStateChange() {
        guard #unavailable(macOS 27) else { return }

        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(_highlightStatusItem), object: nil)
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(_dimStatusItem), object: nil)
    }

    @objc func _highlightStatusItem() {
        guard #unavailable(macOS 27) else { return }

        statusItem?.button?.highlight(true)
    }

    @objc func _dimStatusItem() {
        guard #unavailable(macOS 27) else { return }

        statusItem?.button?.highlight(false)
    }
}

// MARK: - Panel

@Observable
private final class StatusBarMenuPanel: NSPanel {

    private(set) var contentSize: CGSize? = nil

    convenience init(statusItem: NSStatusItem?) {
        self.init(
            contentRect: NSRect(x: 0, y: 0, width: 0, height: 0),
            styleMask: [.fullSizeContentView, .borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false,
            screen: statusItem?.button?.window?.screen
        )
        
        isMovable = false
        titleVisibility = .hidden
        titlebarAppearsTransparent = true
        level = .statusBar
        isOpaque = false
        backgroundColor = .clear
        hasShadow = false
        hidesOnDeactivate = false
    }
    
    override var acceptsFirstResponder: Bool { true }
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }

    override func updateConstraintsIfNeeded() {
        super.updateConstraintsIfNeeded()

        guard let contentViewController else { return }

        let newSize = contentViewController.view.bounds.size

        if let contentSize {
            guard abs(newSize.width - contentSize.width) >= 0.5,
                  abs(newSize.height - contentSize.height) >= 0.5
            else { return }
        }

        self.contentSize = newSize
    }

}
