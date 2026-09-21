//
//  DashboardItemView.swift
//  StatusBuddyNewUIPrototype
//
//  Created by Guilherme Rambo on 28/06/21.
//

import SwiftUI

struct DashboardItemView: View {
    let item: DashboardItem
    
    init(_ item: DashboardItem) {
        self.item = item
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: item.iconName)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .frame(width: 40, height: 40, alignment: .center)
                .foregroundStyle(.white)
                .background(Circle().foregroundStyle(item.iconColor))
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 3) {
                Text(item.title)
                    .foregroundStyle(.primary)
                    .font(.headline)
                Text(item.subtitle)
                    .foregroundStyle(item.subtitleColor)
                    .font(.subheadline)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .accessibilityElement(children: .combine)

            Spacer(minLength: 0)

            Image(systemName: "chevron.forward")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.tertiary)
                .accessibilityHidden(true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .contentShape(.rect(cornerRadius: 16))
    }
}
