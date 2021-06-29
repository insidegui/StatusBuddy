//
//  StatusBarFlowBackgroundView.swift
//  StatusUI
//
//  Created by Guilherme Rambo on 29/06/21.
//  Copyright © 2021 Guilherme Rambo. All rights reserved.
//

import Cocoa

final class StatusBarFlowBackgroundView: NSView {
   
    private lazy var vfxView: NSVisualEffectView = {
        let v = NSVisualEffectView(frame: bounds)
    
        v.autoresizingMask = [.width, .height]
        v.material = .windowBackground
        v.blendingMode = .behindWindow
   
        return v
    }()
   
    override var wantsUpdateLayer: Bool { true }
   
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        wantsLayer = true
        setup()
    }
   
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func setup() {
        vfxView.frame = bounds
        addSubview(vfxView)
        
        layer?.masksToBounds = true
        layer?.cornerRadius = 14
        layer?.cornerCurve = .continuous
    }
}
