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
    
    public static var topMargin: CGFloat { MenuContainerView.topPaddingToAccomodateShadow }
    
    public private(set) lazy var viewModel = MenuViewModel()
    
    private lazy var rootView: NSView = {
        NSHostingView(rootView: MenuContainerView().environmentObject(self.viewModel))
    }()
    
    public convenience init() {
        self.init(nibName: nil, bundle: nil)
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
