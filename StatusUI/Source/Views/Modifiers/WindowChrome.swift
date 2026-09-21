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
            .glassEffect(.regular, in: .rect(cornerRadius: 24))
            // Leave room for the system-rendered glass shadow in the transparent panel.
            .padding(RootView.topPaddingToAccomodateShadow)
    }
}

extension View {
    func windowChrome() -> some View {
        modifier(WindowChromeModifier())
    }
}
