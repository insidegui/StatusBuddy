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

    init(provider: StatusProvider) {
        self.provider = provider

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override func loadView() {
        view = NSView()

        preferredContentSize = NSSize(width: 340, height: 260)

        let contentView = ContentView().environmentObject(provider)
        let hoster = NSHostingController(rootView: contentView)
        addChild(hoster)
        hoster.view.autoresizingMask = [.width, .height]
        hoster.view.frame = view.bounds
        view.addSubview(hoster.view)
    }
    
}
