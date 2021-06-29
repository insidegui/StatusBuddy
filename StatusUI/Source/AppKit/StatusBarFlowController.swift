//
//  StatusBarFlowController.swift
//  StatusUI
//
//  Created by Guilherme Rambo on 29/06/21.
//  Copyright © 2021 Guilherme Rambo. All rights reserved.
//

import Cocoa
import SwiftUI

public final class StatusBarFlowController: NSViewController {
    
    private lazy var viewModel = DashboardViewModel()
    
    private lazy var rootView: NSView = {
        NSHostingView(rootView: DashboardView(viewModel: self.viewModel))
    }()
    
    public convenience init() {
        self.init(nibName: nil, bundle: nil)
    }

    public override func loadView() {
        view = StatusBarFlowBackgroundView()

        rootView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(rootView)
        
        NSLayoutConstraint.activate([
            rootView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            rootView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            rootView.topAnchor.constraint(equalTo: view.topAnchor),
            rootView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        
        preferredContentSize = view.fittingSize
    }
    
    public override func viewWillAppear() {
        super.viewWillAppear()
        
        preferredContentSize = view.fittingSize
    }
    
}
