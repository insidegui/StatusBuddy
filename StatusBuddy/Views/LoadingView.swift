//
//  LoadingView.swift
//  StatusBuddy
//
//  Created by Guilherme Rambo on 11/02/20.
//  Copyright © 2020 Guilherme Rambo. All rights reserved.
//

import SwiftUI
import Cocoa

struct LoadingView: NSViewRepresentable {

    @State var spinning = false

    func makeNSView(context: Context) -> NSProgressIndicator {
        let v = NSProgressIndicator()

        v.controlSize = .small
        v.style = .spinning
        v.isIndeterminate = true
        v.isDisplayedWhenStopped = false

        if self.spinning {
            v.startAnimation(nil)
        }

        return v
    }

    func updateNSView(_ nsView: NSProgressIndicator, context: Context) {
        if spinning {
            nsView.startAnimation(nil)
        } else {
            nsView.stopAnimation(nil)
        }
    }

    typealias NSViewType = NSProgressIndicator

}
