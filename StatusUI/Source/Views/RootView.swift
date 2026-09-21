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
    
    static let chromeShadowPadding: CGFloat = 64
    static let minWidth: CGFloat = 346
    
    var body: some View {
        DashboardView(
            viewModel: viewModel,
            selectedItem: $viewModel.selectedDashboardItem
        )
        .frame(minWidth: Self.minWidth, maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .windowChrome()
        .task { viewModel.startPeriodicUpdates() }
    }
}

#if DEBUG
#Preview {
    RootView()
        .environmentObject(RootViewModel.preview)
}
#endif
