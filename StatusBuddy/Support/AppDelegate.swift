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
    
    private(set) lazy var rootViewModel: RootViewModel = {
        RootViewModel(with: [
            .developer: AppleStatusChecker(endpoint: .developerFeedURL, format: .JSONCallback),
            .customer: AppleStatusChecker(endpoint: .consumerFeedURL, format: .JSON)
        ])
    }()
    
    private lazy var flowController: StatusBarFlowController = {
        StatusBarFlowController(
            viewModel: rootViewModel,
            notificationManager: notificationManager
        )
    }()
     
    private lazy var windowController: StatusBarMenuWindowController = {
        StatusBarMenuWindowController(
            statusItem: statusItem,
            contentViewController: flowController,
            topMargin: StatusBarFlowController.topMargin
        )
    }()
    
    private lazy var notificationManager = NotificationManager()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        updateButton()
        
        windowController.handleEscape = { [weak self] _ in
            self?.hideUI(sender: nil)
        }

        rootViewModel.startPeriodicUpdates()

        rootViewModel.$hasActiveIssues
            .assign(to: \.issueBadgeVisible, on: self)
            .store(in: &cancellables)
        
        rootViewModel.$latestResponses
            .assign(to: \.latestResponses, on: notificationManager)
            .store(in: &cancellables)
        
        preferences.$enableTimeSensitiveNotifications
            .assign(to: \.enableTimeSensitiveNotifications, on: notificationManager.presenter)
            .store(in: &cancellables)
        
        statusItem.button?.menu = contextualMenu
        
        if !preferences.hasLaunchedBefore {
            perform(#selector(showUI(sender:)), with: nil, afterDelay: 0.2)
            
            preferences.hasLaunchedBefore.toggle()
        }
        
        rootViewModel.showSettingsMenu = { [weak self] in
            self?.showSettingsMenuFromUI()
        }
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

    private lazy var badgeView: NSTextField = {
        let v = NSTextField(labelWithString: "!")
        
        v.font = .systemFont(ofSize: 12, weight: .bold)
        v.textColor = .labelColor
        v.translatesAutoresizingMaskIntoConstraints = false
        let s = NSShadow()
        s.shadowColor = NSColor(named: "IssueBadgeColor")
        s.shadowBlurRadius = 1
        s.shadowOffset = .zero
        v.shadow = s

        return v
    }()

    private func updateBadge() {
        guard let button = statusItem.button else { return }

        if badgeView.superview == nil {
            button.addSubview(badgeView)
            NSLayoutConstraint.activate([
                badgeView.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: 0),
                badgeView.bottomAnchor.constraint(equalTo: button.bottomAnchor, constant: 0),
            ])
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

    @objc func showUI(sender: Any?) {
        rootViewModel.refresh(nil)
        
        windowController.showWindow(sender)
    }

    func hideUI(sender: Any?) {
        // Go back if showing detail.
        guard rootViewModel.selectedDashboardItem == nil else {
            rootViewModel.selectedDashboardItem = nil
            return
        }
        
        windowController.close()
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        showUI(sender: nil)
        
        return true
    }
    
    // MARK: - Menu
    
    private lazy var contextualMenu: NSMenu = {
        let m = NSMenu(title: "StatusBuddy")
        
        let prefsItem = NSMenuItem(title: "Preferences…", action: #selector(preferencesMenuItemAction), keyEquivalent: ",")
        prefsItem.target = self
        
        let quitItem = NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate), keyEquivalent: "Q")
        quitItem.target = NSApp
        
        m.addItem(prefsItem)
        m.addItem(.separator())
        m.addItem(quitItem)
        
        return m
    }()
    
    private var preferencesWindowController: NSWindowController?
    
    @objc private func preferencesMenuItemAction(_ sender: NSMenuItem) {
        let controller = HostingWindowController(
            rootView: PreferencesView()
                .padding()
                .environmentObject(preferences)
        )
        
        controller.showWindow(sender)
        
        preferencesWindowController = controller
        
        controller.willClose = { [weak self] _ in
            self?.preferencesWindowController = nil
        }
                
        hideUI(sender: sender)
    }
    
    private func closePreferences() {
        preferencesWindowController?.close()
        preferencesWindowController = nil
    }
    
    @objc private func showSettingsMenuFromUI() {
        contextualMenu.popUp(positioning: nil, at: NSEvent.mouseLocation, in: nil)
    }

}

