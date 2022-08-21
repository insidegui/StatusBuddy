//
//  StatusBarFlowController.swift
//  StatusUI
//
//  Created by Guilherme Rambo on 29/06/21.
//  Copyright © 2021 Guilherme Rambo. All rights reserved.
//

import Cocoa
import SwiftUI
import StatusCore

public final class StatusBarFlowController: NSViewController {
    
    public static var topMargin: CGFloat { RootView.topPaddingToAccomodateShadow }
    
    private lazy var rootView: NSView = {
        let v = RootView()
            .environmentObject(viewModel)
            .environmentObject(notificationManager)
        
        return NSHostingView(rootView: v)
    }()
    
    let viewModel: RootViewModel
    let notificationManager: NotificationManager
    
    public init(viewModel: RootViewModel, notificationManager: NotificationManager) {
        self.viewModel = viewModel
        self.notificationManager = notificationManager
        
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder: NSCoder) {
        fatalError()
    }

    public override func loadView() {
        let containerView = NSView()
        
        view = containerView
        
        containerView.addSubview(rootView)
        rootView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            rootView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            rootView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            rootView.topAnchor.constraint(equalTo: view.topAnchor),
            rootView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        
        preferredContentSize = view.fittingSize
    }
    
}

public extension URL {
    static var developerFeedURL: URL {
        if let overrideStr = UserDefaults.standard.string(forKey: "SBDeveloperFeedURL"),
           let overrideURL = URL(string: overrideStr) {
            return overrideURL
        } else {
            return URL(string: "https://www.apple.com/support/systemstatus/data/developer/system_status_en_US.js?callback=jsonCallback")!
        }
    }
    
    static var consumerFeedURL: URL {
        if let overrideStr = UserDefaults.standard.string(forKey: "SBConsumerFeedURL"),
           let overrideURL = URL(string: overrideStr) {
            return overrideURL
        } else {
            return URL(string: "https://www.apple.com/support/systemstatus/data/system_status_en_US.js")!
        }
    }
}
