//
//  DashboardView.swift
//  StatusBuddyNewUIPrototype
//
//  Created by Guilherme Rambo on 28/06/21.
//

import SwiftUI

struct DashboardView: View {
    @ObservedObject var viewModel: RootViewModel
    @Binding var selectedItem: DashboardItem?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            DashboardHeader(showSettings: viewModel.showSettingsMenu)
            DashboardContent(state: viewModel.dashboard.state, selectedItem: $selectedItem)
        }
        .padding(16)
    }
}

private struct DashboardHeader: View {
    let showSettings: () -> Void

    var body: some View {
        HStack {
            Text("StatusBuddy")
                .font(.system(.headline, design: .rounded))
            Spacer()
            Button(action: showSettings) {
                Label("Settings", systemImage: "gearshape")
                    .labelStyle(.iconOnly)
            }
            .buttonStyle(.bordered)
            .buttonBorderShape(.circle)
            .help("Settings")
        }
    }
}

private struct DashboardContent: View {
    let state: DashboardViewModel.State
    @Binding var selectedItem: DashboardItem?

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            switch state {
            case .loaded(let items):
                ForEach(items) { item in
                    Button {
                        selectedItem = item
                    } label: {
                        DashboardItemView(item)
                    }
                    .buttonStyle(.bordered)
                    .buttonBorderShape(.roundedRectangle(radius: 16))
                }
            case .loading:
                ProgressView()
                    .controlSize(.small)
                    .frame(maxWidth: .infinity, minHeight: 90)
            case .failure(let message):
                Text("Sorry, I couldn't load the status right now.\n\(message)")
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, minHeight: 90)
            }
        }
    }
}

#if DEBUG
#Preview("Dashboard") {
    VStack(alignment: .leading, spacing: 12) {
        DashboardHeader(showSettings: {})
        DashboardContent(state: .loaded([
            DashboardItem(with: .customer),
            DashboardItem(with: .developer)
        ]), selectedItem: .constant(nil))
    }
    .padding(16)
    .frame(width: RootView.minWidth)
    .windowChrome()
}

#Preview("Outages") {
    VStack(alignment: .leading, spacing: 12) {
        DashboardHeader(showSettings: {})
        DashboardContent(state: .loaded([
            DashboardItem(with: .customer, subtitle: "Outage: Maps Routing & Navigation", iconColor: .error, subtitleColor: .error),
            DashboardItem(with: .developer, subtitle: "3 Recent Issues", iconColor: .warning, subtitleColor: .warningText)
        ]), selectedItem: .constant(nil))
    }
    .padding(16)
    .frame(width: RootView.minWidth)
    .windowChrome()
    .preferredColorScheme(.dark)
}
#endif
