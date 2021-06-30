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
    
    init(maxWidth: CGFloat, padding: CGFloat?) {
        self.maxWidth = maxWidth
        self.padding = padding
    }
    
    private struct BackgroundShape: ViewModifier {
        let cornerRadius: CGFloat
        
        func body(content: Content) -> some View {
            if #available(macOS 12.0, *) {
                content
                    .background(Material.thin, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            } else {
                content
                    .background(Color.itemBackground)
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            }
        }
    }

    func body(content: Content) -> some View {
        content
            .padding(.all, padding)
            .frame(maxWidth: maxWidth)
            .modifier(BackgroundShape(cornerRadius: 10))
            .shadow(color: .black.opacity(0.09), radius: 9, x: 0, y: 0)
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
