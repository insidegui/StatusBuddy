//
//  DashboardView.swift
//  StatusBuddyNewUIPrototype
//
//  Created by Guilherme Rambo on 28/06/21.
//

import SwiftUI

struct DashboardView: View {
    @ObservedObject var viewModel = RootViewModel()
    @Binding var selectedItem: DashboardItem?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .bottom) {
                Text("StatusBuddy")
                    .foregroundColor(.accent)
                
                Spacer()
                
                Button {
                    viewModel.showSettingsMenu()
                } label: {
                    Image(systemName: "gearshape.fill")
                }
                .buttonStyle(.borderless)
            }
            .font(.system(size: 15, weight: .semibold, design: .rounded))
            
            Group {
                switch viewModel.dashboard.state {
                case .loaded(let items):
                    itemList(with: items)
                case .loading:
                    loadingView
                        .frame(maxWidth: .infinity, minHeight: 90, maxHeight: .infinity)
                case .failure(let message):
                    failureView(with: message)
                }
            }
        }
        .padding()
    }
    
    @ViewBuilder
    private func itemList(with items: [DashboardItem]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(items) { item in
                DashboardItemView(item)
                    .onTapGesture { selectedItem = item }
            }
        }
    }
    
    private var loadingView: some View {
        ProgressView()
            .progressViewStyle(.circular)
            .controlSize(.small)
    }
    
    @ViewBuilder
    private func failureView(with message: String) -> some View {
        Text("Sorry, I couldn't load the status right now.\n\(message)")
            .font(.system(.caption))
            .multilineTextAlignment(.center)
            .lineLimit(nil)
            .foregroundColor(.secondary)
            .frame(maxHeight: .infinity)
    }
}

#if DEBUG
struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            DashboardView(selectedItem: .constant(nil))
            DashboardView(selectedItem: .constant(nil))
                .preferredColorScheme(.dark)
            DashboardView(viewModel: RootViewModel(dashboard: DashboardViewModel(with: .loaded([
                DashboardItem(with: .customer, subtitle: "Outage: Maps Routing & Navigation", iconColor: .error, subtitleColor: .error),
                DashboardItem(with: .developer, subtitle: "3 Recent Issues", iconColor: .warning, subtitleColor: .warningText)
            ]))), selectedItem: .constant(nil))
        }
    }
}
#endif
