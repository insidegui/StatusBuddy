//
//  HostingWindowController.swift
//  StatusBuddy
//
//  Created by Guilherme Rambo on 21/12/21.
//  Copyright © 2021 Guilherme Rambo. All rights reserved.
//

import Cocoa
import SwiftUI

public final class HostingWindowController<Content>: NSWindowController, NSWindowDelegate where Content: View {
    
    /// Invoked shortly before the hosting window controller's window is closed.
    public var willClose: ((HostingWindowController<Content>) -> Void)?

    public let requiresRegularActivationPolicy: Bool

    public init(rootView: Content, requiresRegularActivationPolicy: Bool = false) {
        self.requiresRegularActivationPolicy = requiresRegularActivationPolicy

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: NSView.noIntrinsicMetric, height: NSView.noIntrinsicMetric),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false,
            screen: nil
        )
        
        window.title = "StatusBuddy Preferences"
        
        super.init(window: window)

        let controller = NSHostingController(
            rootView: rootView
                .environment(\.closeWindow, { [weak self] in self?.close() })
                .environment(\.cocoaWindow, window)
        )
        
        contentViewController = controller
        window.setContentSize(controller.view.fittingSize)
        
        window.isReleasedWhenClosed = false
        window.delegate = self
    }
    
    public required init?(coder: NSCoder) {
        fatalError()
    }

    private var activationPolicyAssertion: AppActivationPolicyAssertion?

    public override func showWindow(_ sender: Any?) {
        super.showWindow(sender)
        
        window?.center()

        if requiresRegularActivationPolicy {
            activationPolicyAssertion = NSApplication.shared.requestRegularActivationPolicy()
        }
    }

    public func windowWillClose(_ notification: Notification) {
        contentViewController = nil
        
        willClose?(self)

        activationPolicyAssertion = nil
    }

    deinit { activationPolicyAssertion = nil }

}
