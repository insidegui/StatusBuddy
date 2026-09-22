//
//  DashboardView.swift
//  StatusBuddyNewUIPrototype
//
//  Created by Guilherme Rambo on 28/06/21.
//

import SwiftUI

struct DashboardView: View {
    let viewModel: RootViewModel
    @Binding var selectedItem: DashboardItem?

    var body: some View {
        GlassEffectContainer {
            VStack(alignment: .leading, spacing: 12) {
                DashboardHeader()

                if let selectedItem {
                    DetailView(
                        viewModel: viewModel,
                        scope: selectedItem.scope,
                        groups: viewModel.details[selectedItem.scope]?.groups ?? []
                    )
                    .frame(minHeight: 323, maxHeight: .infinity, alignment: .topLeading)
                } else {
                    DashboardContent(state: viewModel.dashboard.state, selectedItem: $selectedItem)
                }
            }
            .padding(16)
        }
        .animation(.default, value: selectedItem?.id)
    }
}

private struct DashboardHeader: View {
    @Environment(RootViewModel.self) private var viewModel

    var body: some View {
        HStack {
            Group {
                if let selectedItem = viewModel.selectedDashboardItem {
                    BackButton {
                        viewModel.selectedDashboardItem = nil
                    }

                    Text(selectedItem.scope.title)
                        .font(.system(.headline, design: .rounded))
                } else {
                    Text("StatusBuddy")
                        .font(.system(.headline, design: .rounded))
                }
            }
            .transition(.blurReplace)

            Spacer()

            Button(action: viewModel.showSettingsMenu) {
                Label("Settings", systemImage: "gearshape")
                    .labelStyle(.iconOnly)
            }
            .buttonStyle(.bordered)
            .buttonBorderShape(.circle)
            .help("Settings")
        }
    }

    struct BackButton: View {
        let goBack: () -> ()
        
        var body: some View {
            Button(action: goBack) {
                Label("Back", systemImage: "chevron.backward")
                    .labelStyle(.iconOnly)
            }
            .buttonStyle(.bordered)
            .buttonBorderShape(.circle)
            .keyboardShortcut("[", modifiers: .command)
            .help("Back")
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
        .environment(RootViewModel.preview)
        .frame(width: 600, height: 700, alignment: .top)
}
#endif
