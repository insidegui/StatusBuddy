//
//  RootView.swift
//  StatusUI
//
//  Created by Guilherme Rambo on 29/06/21.
//  Copyright © 2021 Guilherme Rambo. All rights reserved.
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject var viewModel: RootViewModel
    
    static let shadowRadius: CGFloat = 10
    static let topPaddingToAccomodateShadow: CGFloat = 26
    static let minWidth: CGFloat = 346
    
    var body: some View {
        Group {
            if let selectedItem = viewModel.selectedDashboardItem {
                DetailView(
                    viewModel: viewModel,
                    scope: selectedItem.scope,
                    groups: viewModel.details[selectedItem.scope]?.groups ?? []
                )
                    .frame(minWidth: Self.minWidth, maxWidth: .infinity, minHeight: 323, maxHeight: .infinity, alignment: .topLeading)
                    .windowChrome(shadowRadius: Self.shadowRadius, padding: Self.topPaddingToAccomodateShadow)
            } else {
                DashboardView(
                    viewModel: viewModel,
                    selectedItem: $viewModel.selectedDashboardItem
                )
                    .frame(minWidth: Self.minWidth, maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .windowChrome(shadowRadius: Self.shadowRadius, padding: Self.topPaddingToAccomodateShadow)
            }
        }
        .onAppear {
            viewModel.refresh()
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
            .environmentObject(RootViewModel(with: [:]))
    }
}
