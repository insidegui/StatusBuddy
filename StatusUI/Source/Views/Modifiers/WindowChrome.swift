//
//  WindowChrome.swift
//  StatusUI
//
//  Created by Guilherme Rambo on 29/06/21.
//  Copyright © 2021 Guilherme Rambo. All rights reserved.
//

import SwiftUI

private struct WindowChromeModifier: ViewModifier {
    
    let cornerRadius: CGFloat
    let shadowRadius: CGFloat
    let padding: CGFloat
    
    func body(content: Content) -> some View {
        content
            .background(Color.background)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .shadow(color: Color.black.opacity(0.3), radius: shadowRadius)
            .shadow(color: Color.black.opacity(0.5), radius: 1, x: 0, y: 0)
            .padding(padding)
    }
    
}

extension View {
    func windowChrome(cornerRadius: CGFloat = 14, shadowRadius: CGFloat, padding: CGFloat) -> some View {
        self.modifier(WindowChromeModifier(cornerRadius: cornerRadius, shadowRadius: shadowRadius, padding: padding))
    }
}
