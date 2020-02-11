//
//  AppDelegate.swift
//  StatusBuddy
//
//  Created by Guilherme Rambo on 11/02/20.
//  Copyright © 2020 Guilherme Rambo. All rights reserved.
//

import Cocoa
import SwiftUI
import StatusCore
import Combine

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var window: NSWindow!

    private lazy var provider: StatusProvider = {
        StatusProvider()
    }()

    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

    private var cancellables: [Cancellable] = []

    private lazy var popover = NSPopover()

    private lazy var statusController: StatusViewController = {
        StatusViewController(provider: provider, preferences: preferences)
    }()

    private let preferences = Preferences()

    private var eventMonitor: EventMonitor?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let activeIssuesBinding = provider.$activeIssues.receive(on: DispatchQueue.main).map({ !$0.isEmpty }).sink { [weak self] value in
            self?.issueBadgeVisible = value
        }

        cancellables.append(activeIssuesBinding)

        updateButton()

        popover.contentViewController = statusController

        eventMonitor = EventMonitor(mask: [.leftMouseDown, .rightMouseDown]) { [weak self] event in
            guard let self = self else { return }
            guard self.popover.isShown else { return }

            self.closePopover(sender: event)
        }
    }

    private var imageForCurrentStatus: NSImage? {
        NSImage(named: .init("statusbutton"))
    }

    private func updateButton() {
        guard let button = statusItem.button else { return }

        button.image = imageForCurrentStatus
        button.image?.size = NSSize(width: 20, height: 20)
        button.action = #selector(togglePopover)
    }

    private var issueBadgeVisible: Bool = false {
        didSet {
            guard issueBadgeVisible != oldValue else { return }

            updateBadge()
        }
    }

    private lazy var badgeView: NSImageView = {
        let image = NSImage(named: .init("issuebadge"))!
        image.size = NSSize(width: 20, height: 20)

        let v = NSImageView(image: image)

        v.imageScaling = .scaleProportionallyDown

        return v
    }()

    private func updateBadge() {
        guard let button = statusItem.button else { return }

        if badgeView.superview == nil {
            badgeView.frame = button.bounds
            button.addSubview(badgeView)
        }

        badgeView.isHidden = !issueBadgeVisible
    }

    @objc func togglePopover(_ sender: Any?) {
        if popover.isShown {
            closePopover(sender: sender)
        } else {
            showPopover(sender: sender)
        }
    }

    func showPopover(sender: Any?) {
        guard let button = statusItem.button else { return }

        eventMonitor?.start()

        popover.show(
            relativeTo: button.bounds,
            of: button,
            preferredEdge: NSRectEdge.minY
        )
    }

    func closePopover(sender: Any?) {
        popover.performClose(sender)

        eventMonitor?.stop()
    }

}

