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
import StatusUI

#if ENABLE_SPARKLE
import Sparkle
#endif

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    #if ENABLE_SPARKLE
    @IBOutlet weak var updaterController: SPUStandardUpdaterController?
    #endif

    var window: NSWindow!

    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

    private lazy var cancellables = Set<AnyCancellable>()

    private let preferences = Preferences()
    
    private lazy var flowController: StatusBarFlowController = {
        StatusBarFlowController()
    }()
     
    private lazy var windowController: StatusBarMenuWindowController = {
        StatusBarMenuWindowController(
            statusItem: statusItem,
            contentViewController: flowController,
            topMargin: StatusBarFlowController.topMargin
        )
    }()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        updateButton()
        
        windowController.handleEscape = { [weak self] _ in
            self?.hideUI(sender: nil)
        }
        
        flowController.viewModel.$hasActiveIssues
            .assign(to: \.issueBadgeVisible, on: self)
            .store(in: &cancellables)
    }

    private var imageForCurrentStatus: NSImage? {
        NSImage(named: .init("statusbutton"))
    }

    private func updateButton() {
        guard let button = statusItem.button else { return }

        button.image = imageForCurrentStatus
        button.image?.size = NSSize(width: 20, height: 20)
        button.action = #selector(toggleUI)
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

    @objc func toggleUI(_ sender: Any?) {
        if windowController.window?.isVisible == true {
            hideUI(sender: sender)
        } else {
            showUI(sender: sender)
        }
    }

    func showUI(sender: Any?) {
        windowController.showWindow(sender)
    }

    func hideUI(sender: Any?) {
        // Go back if showing detail.
        guard flowController.viewModel.selectedDashboardItem == nil else {
            flowController.viewModel.selectedDashboardItem = nil
            return
        }
        
        windowController.close()
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        showUI(sender: nil)
        
        return true
    }

}

