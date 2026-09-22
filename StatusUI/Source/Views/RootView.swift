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
    @Environment(WindowGeometry.self) private var geometry

    public static let chromeShadowPadding: CGFloat = 64
    public static let minWidth: CGFloat = 400

    public init() { }

    public var body: some View {
        DashboardView(
            viewModel: viewModel,
            maximumHeight: min(560, max(1, geometry.maximumContentHeight - Self.chromeShadowPadding * 2))
        )
        .frame(width: Self.minWidth)
        .windowChrome()
        .task { viewModel.startPeriodicUpdates() }
    }
}

#if DEBUG
#Preview {
    RootView()
        .environment(RootViewModel.preview)
        .environment(WindowGeometry(layout: .default))
        .environment(NotificationManager())
        .frame(width: 600, height: 800, alignment: .top)
}
#endif
