//
//  StatusBarMenuWindowController.swift
//  StatusUI
//
//  Created by Gui Rambo on 04/12/20.
//

import AppKit
import os.log

@MainActor
public final class StatusBarMenuWindowController: NSWindowController {
    
    private let log = OSLog(subsystem: StatusUI.subsystemName, category: String(describing: StatusBarMenuWindowController.self))
    
    public let statusItem: NSStatusItem?
    
    public var windowWillClose: () -> Void = { }
    
    let topMargin: CGFloat

    public init(statusItem: NSStatusItem?, contentViewController: NSViewController, topMargin: CGFloat = 0) {
        self.statusItem = statusItem
        self.topMargin = topMargin
        
        let window = StatusBarMenuPanel(statusItem: statusItem)
        window.contentViewController = contentViewController

        super.init(window: window)
        
        window.delegate = self
        setupContentSizeObservation()
    }
    
    public required init?(coder: NSCoder) {
        fatalError()
    }

    /// Tracks show / hide requests to prevent race conditions caused by rapid repeated calls to `showWindow` and `close(animated:)`.
    private var visibilityToken: UUID?

    public override func showWindow(_ sender: Any?) {
        /// Reset token so that a racing call to `close(animated:)` doesn't actually close the window.
        visibilityToken = nil

        repositionWindow()
        
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
                os_log("Close cancelled by visibility token race", log: self.log, type: .debug)
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
    
    @objc private func repositionWindow() {
        guard let referenceWindow = statusItem?.button?.window, let window = window else {
            os_log("Couldn't find reference window for repositioning status bar menu window, centering instead", log: self.log, type: .debug)
            self.window?.center()
            return
        }
        
        let width = contentViewController?.preferredContentSize.width ?? window.frame.width
        let height = contentViewController?.preferredContentSize.height ?? window.frame.height
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
    
    private var contentSizeObservation: NSKeyValueObservation?
    
    public override var contentViewController: NSViewController? {
        didSet {
            setupContentSizeObservation()
        }
    }
    
    private var previouslyObservedContentSize: NSSize?
    
    private func setupContentSizeObservation() {
        contentSizeObservation?.invalidate()
        contentSizeObservation = nil
        
        guard let controller = contentViewController else { return }
        
        contentSizeObservation = controller.observe(\.preferredContentSize, options: [.initial, .new]) { [weak self] controller, _ in
            MainActor.assumeIsolated {
                self?.updateForNewContentSize(from: controller)
            }
        }
    }
    
    private func updateForNewContentSize(from controller: NSViewController) {
        defer { previouslyObservedContentSize = controller.preferredContentSize }
        
        guard controller.preferredContentSize != previouslyObservedContentSize else { return }
        
        repositionWindow()
    }

}

// MARK: - Window delegate

extension StatusBarMenuWindowController: NSWindowDelegate {
    
    public func windowWillClose(_ notification: Notification) {
        windowWillClose()
    }
    
    public func windowDidBecomeKey(_ notification: Notification) {
        highlightStatusItem()
    }

    public func windowDidResignKey(_ notification: Notification) {
        dimStatusItem()
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

private final class StatusBarMenuPanel: NSPanel {

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
    
}
