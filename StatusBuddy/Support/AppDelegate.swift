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
import StatusUI
import OSLog
import Observation

@MainActor
@NSApplicationMain
final class AppDelegate: NSObject, NSApplicationDelegate {

    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "StatusBuddy", category: String(describing: AppDelegate.self))

    private lazy var updateController = UpdateController()

    var window: NSWindow!

    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

    private let preferences = Preferences()
    
    private(set) lazy var rootViewModel: RootViewModel = {
        #if DEBUG
        if UserDefaults.standard.bool(forKey: "SBUsePreviewData") {
            RootViewModel.preview
        } else {
            RootViewModel.default
        }
        #else
        RootViewModel.default
        #endif
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

    private lazy var statusItemController = StatusItemController(statusItem: statusItem, delegate: self)

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        logger.debug(#function)

        updateButton()

        statusItemController.configure()

        rootViewModel.startPeriodicUpdates()

        observeModelChanges()
        
        statusItem.button?.menu = contextualMenu
        
        if !preferences.hasLaunchedBefore {
            perform(#selector(showUI(sender:)), with: nil, afterDelay: 0.2)
            
            preferences.hasLaunchedBefore.toggle()
        }
        
        rootViewModel.showSettingsMenu = { [weak self] in
            self?.showSettingsMenuFromUI()
        }

        updateController.activate()
    }

    private func observeModelChanges() {
        withObservationTracking {
            issueBadgeVisible = rootViewModel.hasActiveIssues
            notificationManager.latestResponses = rootViewModel.latestResponses
            notificationManager.presenter.enableTimeSensitiveNotifications = preferences.enableTimeSensitiveNotifications
        } onChange: { [weak self] in
            Task { @MainActor in
                self?.observeModelChanges()
            }
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
        logger.notice(#function)

        if windowController.window?.isVisible == true {
            hideUI(sender: sender)
        } else {
            showUI(sender: sender)
        }
    }

    @objc func showUI(sender: Any?) {
        logger.notice(#function)

        statusItemController.showPanel()
    }

    func hideUI(sender: Any?) {
        logger.notice(#function)

        if #unavailable(macOS 27) {
            guard !navigateBackInResponseToStatusItemClick() else {
                /// Button can have its highlight state reset because user clicked on it, bring it back to highlighted state.
                windowController.highlightStatusItem()
                return
            }
        }
        
        statusItemController.hidePanel()
    }

    func navigateBackInResponseToStatusItemClick() -> Bool {
        guard rootViewModel.selectedDashboardItem != nil else { return false }

        logger.notice("Navigating back in response to status item click")

        rootViewModel.selectedDashboardItem = nil

        return true
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        logger.notice("Handle reopen")

        /// Do not show UI in response to reopen if preferences window is currently visible.
        guard preferencesWindowController?.window?.isVisible != true else {
            return false
        }

        showUI(sender: nil)
        
        return true
    }

    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        logger.notice("Should terminate")

        /// This is currently only used for menu bar unlock in macOS versions before macOS 27.
        guard #unavailable(macOS 27) else { return .terminateNow }

        windowController.unlockMenuBar()

        /// Give the app enough time to deliver the menu bar unlocking notification to the system.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            self.logger.notice("Replying to should terminate")
            sender.reply(toApplicationShouldTerminate: true)
        }

        return .terminateLater
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
        defer { hideUI(sender: sender) }

        if let preferencesWindowController {
            preferencesWindowController.showWindow(sender)
            return
        }

        let controller = HostingWindowController(
            rootView: PreferencesView()
                .environment(preferences)
                .environment(updateController),
            requiresRegularActivationPolicy: true
        )
        
        controller.showWindow(sender)
        
        preferencesWindowController = controller
        
        controller.willClose = { [weak self] _ in
            self?.preferencesWindowController = nil
        }
    }
    
    private func closePreferences() {
        preferencesWindowController?.close()
        preferencesWindowController = nil
    }
    
    @objc private func showSettingsMenuFromUI() {
        contextualMenu.popUp(positioning: nil, at: NSEvent.mouseLocation, in: nil)
    }

}

extension AppDelegate: StatusItemControllerDelegate {
    func statusItemControllerIsPanelVisible(_ controller: StatusItemController) -> Bool {
        windowController.window?.isVisible == true
    }

    func statusItemControllerDidRequestShowPanel(_ controller: StatusItemController) {
        windowController.showWindow(self)
    }

    func statusItemControllerDidRequestHidePanel(_ controller: StatusItemController, animated: Bool) {
        windowController.close(animated: animated)
    }

    func statusItemControllerWillShowPanel(_ controller: StatusItemController) {
        rootViewModel.refresh(nil)
    }

    func statusItemControllerWillHidePanel(_ controller: StatusItemController) {
        
    }

    func statusItemControllerShouldHidePanelInResponseToStatusItemClick(_ controller: StatusItemController) -> Bool {
        !navigateBackInResponseToStatusItemClick()
    }
}
