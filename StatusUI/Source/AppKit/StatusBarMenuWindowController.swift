//
//  StatusBarMenuWindowController.swift
//  StatusUI
//
//  Created by Gui Rambo on 04/12/20.
//

import AppKit
import os.log

public final class StatusBarMenuWindowController: NSWindowController {
    
    private let log = OSLog(subsystem: StatusUI.subsystemName, category: String(describing: StatusBarMenuWindowController.self))
    
    public let statusItem: NSStatusItem?
    
    public var windowWillClose: () -> Void = { }
    
    let topMargin: CGFloat

    public init(statusItem: NSStatusItem?, contentViewController: NSViewController, topMargin: CGFloat = 0) {
        self.statusItem = statusItem
        self.topMargin = topMargin
        
        let window = StatusBarMenuWindow(statusItem: statusItem)
        window.contentViewController = contentViewController

        super.init(window: window)
        
        window.delegate = self
        setupContentSizeObservation()
    }
    
    public required init?(coder: NSCoder) {
        fatalError()
    }
    
    private var clickOutsideEventMonitor: EventMonitor?
    private var escapeKeyEventMonitor: Any?
    
    private func postBeginMenuTrackingNotification() {
        DistributedNotificationCenter.default().post(name: .init("com.apple.HIToolbox.beginMenuTrackingNotification"), object: nil)
    }
    
    private func postEndMenuTrackingNotification() {
        DistributedNotificationCenter.default().post(name: .init("com.apple.HIToolbox.endMenuTrackingNotification"), object: nil)
    }
    
    public override func showWindow(_ sender: Any?) {
        postBeginMenuTrackingNotification()
        
        NSApp.activate(ignoringOtherApps: true)

        repositionWindow()
        
        window?.alphaValue = 1
        
        super.showWindow(sender)
        
        startMonitoringInterestingEvents()
    }
    
    public var handleEscape: ((StatusBarMenuWindowController) -> Void)?
    
    private func startMonitoringInterestingEvents() {
        clickOutsideEventMonitor = EventMonitor(mask: [.leftMouseDown, .rightMouseDown], handler: { [weak self] event in
            guard let self = self else { return }
            
            #if DEBUG
            guard !UserDefaults.standard.bool(forKey: "EnableStickyMenuBarWindow") else { return }
            #endif
            
            self.close()
        })
        clickOutsideEventMonitor?.start()
        
        escapeKeyEventMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event -> NSEvent? in
            guard let self = self else { return event }

            if event.keyCode == 53 {
                if let handleEscape = self.handleEscape {
                    handleEscape(self)
                } else {
                    self.close()
                }
                return nil
            } else {
                return event
            }
        }
    }
    
    private func stopMonitoringEvents() {
        clickOutsideEventMonitor?.stop()
        clickOutsideEventMonitor = nil
        
        if let escapeMonitor = escapeKeyEventMonitor {
            NSEvent.removeMonitor(escapeMonitor)
            escapeKeyEventMonitor = nil
        }
    }
    
    public override func close() {
        postEndMenuTrackingNotification()
        
        NSAnimationContext.beginGrouping()
        NSAnimationContext.current.completionHandler = {
            super.close()
            
            self.stopMonitoringEvents()
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
            self?.updateForNewContentSize(from: controller)
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
        statusItem?.button?.highlight(true)
    }
    
    public func windowDidResignKey(_ notification: Notification) {
        statusItem?.button?.highlight(false)
    }
    
}

private final class StatusBarMenuWindow: NSWindow {
    
    convenience init(statusItem: NSStatusItem?) {
        self.init(
            contentRect: NSRect(x: 0, y: 0, width: 0, height: 0),
            styleMask: [.fullSizeContentView, .borderless],
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
    }
    
    override var acceptsFirstResponder: Bool { true }
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }
    
}
