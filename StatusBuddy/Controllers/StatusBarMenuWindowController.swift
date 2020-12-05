//
//  StatusBarMenuWindowController.swift
//  StatusBuddy
//
//  Created by Gui Rambo on 04/12/20.
//

import Cocoa
import os.log

final class StatusBarMenuWindowController: NSWindowController {
    
    private let log = OSLog(subsystem: "StatusBuddy", category: String(describing: StatusBarMenuWindowController.self))
    
    let statusItem: NSStatusItem?
    
    var windowWillClose: () -> Void = { }

    init(statusItem: NSStatusItem?, contentViewController: NSViewController) {
        self.statusItem = statusItem
        
        let window = NSWindow(
            contentRect: NSRect(origin: .zero, size: contentViewController.preferredContentSize),
            styleMask: [.fullSizeContentView, .titled],
            backing: .buffered,
            defer: false,
            screen: statusItem?.button?.window?.screen
        )
        
        window.isMovable = false
        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true
        window.level = .statusBar
        window.contentViewController = contentViewController
        window.isOpaque = false
        window.backgroundColor = .clear
        
        super.init(window: window)
        
        window.delegate = self
        setupContentSizeObservation()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private var eventMonitor: EventMonitor?
    
    private func postBeginMenuTrackingNotification() {
        DistributedNotificationCenter.default().post(name: .init("com.apple.HIToolbox.beginMenuTrackingNotification"), object: nil)
    }
    
    private func postEndMenuTrackingNotification() {
        DistributedNotificationCenter.default().post(name: .init("com.apple.HIToolbox.endMenuTrackingNotification"), object: nil)
    }
    
    override func showWindow(_ sender: Any?) {
        postBeginMenuTrackingNotification()
        
        NSApp.activate(ignoringOtherApps: true)

        repositionWindow()
        
        window?.alphaValue = 1
        
        super.showWindow(sender)
        
        startMonitoringClicks()
    }
    
    private func startMonitoringClicks() {
        eventMonitor = EventMonitor(mask: [.leftMouseDown, .rightMouseDown], handler: { [weak self] event in
            guard let self = self else { return }
            self.close()
        })
        eventMonitor?.start()
    }
    
    override func close() {
        postEndMenuTrackingNotification()
        
        NSAnimationContext.beginGrouping()
        NSAnimationContext.current.completionHandler = {
            super.close()
            
            self.eventMonitor?.stop()
            self.eventMonitor = nil
        }
        window?.animator().alphaValue = 0
        NSAnimationContext.endGrouping()
    }
    
    // MARK: - Positioning relative to status item
    
    private struct Metrics {
        static let verticalMargin: CGFloat = 5
    }
    
    @objc func repositionWindow() {
        guard let referenceWindow = statusItem?.button?.window, let window = window else {
            os_log("Couldn't find reference window for repositioning status bar menu window, centering instead", log: self.log, type: .debug)
            self.window?.center()
            return
        }
        
        let width = contentViewController?.preferredContentSize.width ?? window.frame.width
        let height = contentViewController?.preferredContentSize.height ?? window.frame.height
        
        let rect = NSRect(
            x: referenceWindow.frame.origin.x + referenceWindow.frame.width / 2 - window.frame.width / 2,
            y: referenceWindow.frame.origin.y - height - Metrics.verticalMargin,
            width: width,
            height: height
        )
        
        window.setFrame(rect, display: true, animate: false)
    }
    
    // MARK: - Auto size/position based on content controller
    
    private var contentSizeObservation: NSKeyValueObservation?
    
    override var contentViewController: NSViewController? {
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
    
    func windowWillClose(_ notification: Notification) {
        windowWillClose()
    }
    
    func windowDidBecomeKey(_ notification: Notification) {
        statusItem?.button?.highlight(true)
    }
    
    func windowDidResignKey(_ notification: Notification) {
        statusItem?.button?.highlight(false)
    }
    
}
