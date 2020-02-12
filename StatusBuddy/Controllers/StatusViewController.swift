//
//  StatusViewController.swift
//  StatusBuddy
//
//  Created by Guilherme Rambo on 11/02/20.
//  Copyright © 2020 Guilherme Rambo. All rights reserved.
//

import Cocoa
import Combine
import SwiftUI
import StatusCore

class StatusViewController: NSViewController {

    let provider: StatusProvider
    let preferences: Preferences

    init(provider: StatusProvider, preferences: Preferences) {
        self.provider = provider
        self.preferences = preferences

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override func loadView() {
        view = NSView()

        preferredContentSize = NSSize(width: 340, height: 280)

        let contentView = MainView()
            .environmentObject(provider)
            .environmentObject(preferences)
        let hoster = NSHostingController(rootView: contentView)
        addChild(hoster)
        hoster.view.autoresizingMask = [.width, .height]
        hoster.view.frame = view.bounds
        view.addSubview(hoster.view)
    }
    
}
