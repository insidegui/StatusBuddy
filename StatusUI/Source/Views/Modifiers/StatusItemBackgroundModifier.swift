//
//  StatusItemBackgroundModifier.swift
//  StatusBuddyNewUIPrototype
//
//  Created by Guilherme Rambo on 28/06/21.
//

import SwiftUI

fileprivate struct ItemBackgroundModifier: ViewModifier {
    let maxWidth: CGFloat
    let padding: CGFloat?
    let cornerRadius: CGFloat
    
    init(maxWidth: CGFloat, padding: CGFloat?, cornerRadius: CGFloat = 10) {
        self.maxWidth = maxWidth
        self.padding = padding
        self.cornerRadius = cornerRadius
    }
    
    private var shape: some Shape {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
    }

    func body(content: Content) -> some View {
        if #available(macOS 12.0, *) {
            content
                .padding(.all, padding)
                .frame(maxWidth: maxWidth, alignment: .leading)
                .background(Material.thin, in: shape)
                .overlay(shape.stroke(Color.white.opacity(0.1), lineWidth: .onePixel))
                .shadow(color: .menuBarItemShadow, radius: 7, x: -1.5, y: 1.5)
                .shadow(color: .menuBarItemSecondaryShadow, radius: 1, x: 0, y: 0)
        } else {
            content
                .background(Color.itemBackground)
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        }
    }
}

extension View {
    func statusItemBackground(maxWidth: CGFloat = 320, padding: CGFloat? = nil) -> some View {
        self.modifier(
            ItemBackgroundModifier(
                maxWidth: maxWidth,
                padding: padding
            )
        )
    }
}

extension Color {
    static let menuBarItemShadow = Color("MenuBarContentShadowColor", bundle: .statusUI)
    static let menuBarItemSecondaryShadow = Color("MenuBarContentSecondaryShadowColor", bundle: .statusUI)
}
