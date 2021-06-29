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
    
    static let shadowRadius: CGFloat = 10
    static let topPaddingToAccomodateShadow: CGFloat = 26
    static let minWidth: CGFloat = 346
    
    var body: some View {
        Group {
            if let selectedItem = viewModel.selectedDashboardItem {
                #warning("TODO: respect selectedItem")
                DetailView()
                    .frame(minWidth: Self.minWidth, maxWidth: .infinity, minHeight: 323, maxHeight: .infinity, alignment: .topLeading)
                    .windowChrome(shadowRadius: Self.shadowRadius, padding: Self.topPaddingToAccomodateShadow)
                    .transition(.scale.combined(with: .opacity))
            } else {
                DashboardView(
                    viewModel: viewModel.dashboard,
                    selectedItem: $viewModel.selectedDashboardItem
                )
                    .frame(minWidth: Self.minWidth, maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .windowChrome(shadowRadius: Self.shadowRadius, padding: Self.topPaddingToAccomodateShadow)
                    .transition(.scale.combined(with: .opacity))
            }
        }
    }
}

struct MenuContainerView_Previews: PreviewProvider {
    static var previews: some View {
        MenuContainerView()
            .environmentObject(MenuViewModel())
    }
}
