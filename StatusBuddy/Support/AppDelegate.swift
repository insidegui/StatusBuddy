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

    private lazy var statusController: StatusViewController = {
        StatusViewController(provider: provider, preferences: preferences)
    }()
    
    private lazy var windowController: StatusBarMenuWindowController = {
        StatusBarMenuWindowController(
            statusItem: statusItem,
            contentViewController: statusController
        )
    }()

    private let preferences = Preferences()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let activeIssuesBinding = provider.$activeIssues.receive(on: DispatchQueue.main).map({ !$0.isEmpty }).sink { [weak self] value in
            self?.issueBadgeVisible = value
        }

        cancellables.append(activeIssuesBinding)

        updateButton()
    }

    private var imageForCurrentStatus: NSImage? {
        NSImage(named: .init("statusbutton"))
    }

    private func updateButton() {
        guard let button = statusItem.button else { return }

        button.image = imageForCurrentStatus
        button.image?.size = NSSize(width: 20, height: 20)
        button.action = #selector(toggleMenuVisible)
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

    @objc func toggleMenuVisible(_ sender: Any?) {
        if windowController.window == nil || windowController.window?.isVisible == false {
            showMenu(sender: sender)
        } else {
            hideMenu(sender: sender)
        }
    }

    func showMenu(sender: Any?) {
        windowController.showWindow(sender)
    }

    func hideMenu(sender: Any?) {
        windowController.close()
    }

}

