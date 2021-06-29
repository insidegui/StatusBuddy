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
        HStack {
            Image(systemName: item.iconName)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .frame(width: 40, height: 40, alignment: .center)
                .foregroundColor(.white)
                .background(Circle().foregroundColor(item.iconColor))
                .accessibility(hidden: true)
            VStack(alignment: .leading, spacing: 3) {
                Text(item.title)
                    .foregroundColor(.primaryText)
                    .font(.headline)
                Text(item.subtitle)
                    .foregroundColor(item.subtitleColor)
                    .font(.subheadline)
            }
            .accessibilityElement(children: .combine)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .statusItemBackground()
    }
}
