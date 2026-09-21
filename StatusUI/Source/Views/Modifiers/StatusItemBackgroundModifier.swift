//
//  StatusItemBackgroundModifier.swift
//  StatusBuddyNewUIPrototype
//
//  Created by Guilherme Rambo on 28/06/21.
//

import SwiftUI

private struct ItemBackgroundModifier: ViewModifier {
    let maxWidth: CGFloat
    let padding: CGFloat?

    func body(content: Content) -> some View {
        content
            .padding(.all, padding)
            .frame(maxWidth: maxWidth, alignment: .leading)
            .background(.quaternary, in: .rect(cornerRadius: 16))
    }
}

extension View {
    func statusItemBackground(maxWidth: CGFloat = .infinity, padding: CGFloat? = nil) -> some View {
        modifier(ItemBackgroundModifier(maxWidth: maxWidth, padding: padding))
    }
}
