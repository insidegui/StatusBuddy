//
//  StatusBarMenuBackgroundView.swift
//  StatusBuddy
//
//  Created by Gui Rambo on 04/12/20.
//  Copyright © 2020 Guilherme Rambo. All rights reserved.
//

import Cocoa

final class StatusBarMenuBackgroundView: NSView {

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
        
        if #available(macOS 10.15, *) {
            layer?.cornerCurve = .continuous
        }
    }
    
}
