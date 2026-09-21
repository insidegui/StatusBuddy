//
//  WindowChrome.swift
//  StatusUI
//
//  Created by Guilherme Rambo on 29/06/21.
//  Copyright © 2021 Guilherme Rambo. All rights reserved.
//

import SwiftUI

private struct WindowChromeModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .containerShape(shape)
            .glassEffect(.regular, in: shape)
            // Leave room for the system-rendered glass shadow in the transparent panel.
            .padding(RootView.chromeShadowPadding)
    }

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: 32)
    }
}

extension View {
    func windowChrome() -> some View {
        modifier(WindowChromeModifier())
    }
}
