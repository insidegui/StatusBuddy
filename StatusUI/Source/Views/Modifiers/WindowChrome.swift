//
//  WindowChrome.swift
//  StatusUI
//
//  Created by Guilherme Rambo on 29/06/21.
//  Copyright © 2021 Guilherme Rambo. All rights reserved.
//

import SwiftUI

struct WindowChromeConfiguration {
    var cornerRadius: CGFloat
    var shadowRadius: CGFloat
    var smallShadowRadius: CGFloat
    var shadowOpacity: CGFloat
    var smallShadowOpacity: CGFloat
    var padding: CGFloat
}

private struct WindowChromeModifier: ViewModifier {
    
    private struct BackgroundShape: ViewModifier {
        let cornerRadius: CGFloat
        
        private var shape: some Shape {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        }
        
        func body(content: Content) -> some View {
            if #available(macOS 12.0, *) {
                content
                    .overlay(shape.stroke(Color.white.opacity(0.4), lineWidth: .onePixel))
                    .background(Material.ultraThin, in: shape)
            } else {
                content
                    .background(Color.background)
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            }
        }
    }
    
    let configuration: WindowChromeConfiguration
    
    func body(content: Content) -> some View {
            content
                .modifier(BackgroundShape(cornerRadius: configuration.cornerRadius))
                .clipShape(RoundedRectangle(cornerRadius: configuration.cornerRadius, style: .continuous))
                .shadow(color: Color.black.opacity(configuration.shadowOpacity), radius: configuration.shadowRadius)
                .shadow(color: Color.black.opacity(configuration.smallShadowOpacity), radius: configuration.smallShadowRadius, x: 0, y: 0)
                .padding(configuration.padding)
    }
    
}

extension View {
    func windowChrome(_ configuration: WindowChromeConfiguration) -> some View {
        self.modifier(WindowChromeModifier(configuration: configuration))
    }
}

extension CGFloat {
    
    static let onePixel: CGFloat = {
        #if os(iOS)
        return 1 / UIScreen.main.nativeScale
        #elseif os(watchOS)
        return 1
        #else
        let scale = NSScreen.main?.backingScaleFactor ?? 2
        return 1 / scale
        #endif
    }()
    
}

extension WindowChromeConfiguration {
    static let `default` = WindowChromeConfiguration(cornerRadius: 16.0, shadowRadius: 10.0, smallShadowRadius: 1.438049853372434, shadowOpacity: 0.22, smallShadowOpacity: 0.5210904255319149, padding: 26.0)
}
