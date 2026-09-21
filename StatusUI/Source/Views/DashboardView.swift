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
                    .buttonStyle(DashboardButtonStyle())
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

private struct DashboardButtonStyle: ButtonStyle {
    @Environment(\.colorScheme) private var colorScheme

    private var pressColor: Color { colorScheme == .dark ? .white : .black }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(4)
            .glassEffect(.regular.interactive().tint(configuration.isPressed ? pressColor.opacity(0.07) : nil), in: .containerRelative)
    }
}

#if DEBUG
#Preview("Dashboard") {
    RootView()
        .environmentObject(RootViewModel.preview)
        .frame(width: 600, height: 700, alignment: .top)
}
#endif
