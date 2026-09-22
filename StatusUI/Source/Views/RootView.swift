//
//  RootView.swift
//  StatusUI
//
//  Created by Guilherme Rambo on 29/06/21.
//  Copyright © 2021 Guilherme Rambo. All rights reserved.
//

import SwiftUI

public struct RootView: View {
    @Environment(RootViewModel.self) private var viewModel
    
    public static let chromeShadowPadding: CGFloat = 64
    public static let minWidth: CGFloat = 346

    public init() { }

    public var body: some View {
        @Bindable var viewModel = viewModel

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
        .environment(RootViewModel.preview)
        .frame(width: 600, height: 800, alignment: .top)
}
#endif
