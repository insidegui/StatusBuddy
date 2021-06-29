//
//  MenuContainerView.swift
//  StatusUI
//
//  Created by Guilherme Rambo on 29/06/21.
//  Copyright © 2021 Guilherme Rambo. All rights reserved.
//

import SwiftUI

struct MenuContainerView: View {
    @EnvironmentObject var viewModel: MenuViewModel
    
    private var preferredHeight: CGFloat? { viewModel.selectedDashboardItem != nil ? 323 : nil }

    var body: some View {
        Group {
            if let selectedItem = viewModel.selectedDashboardItem {
                #warning("TODO: respect selectedItem")
                DetailView()
            } else {
                DashboardView(
                    viewModel: viewModel.dashboard,
                    selectedItem: $viewModel.selectedDashboardItem
                )
            }
        }
        .frame(minWidth: 346, maxWidth: .infinity, minHeight: preferredHeight, maxHeight: .infinity)
        .background(Color.background)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

struct MenuContainerView_Previews: PreviewProvider {
    static var previews: some View {
        MenuContainerView()
            .environmentObject(MenuViewModel())
    }
}
