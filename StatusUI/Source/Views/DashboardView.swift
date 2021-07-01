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
            ForEach(viewModel.dashboard.items) { item in
                DashboardItemView(item)
                    .onTapGesture { selectedItem = item }
            }
        }
        .padding()
    }
}

#if DEBUG
struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            DashboardView(selectedItem: .constant(nil))
            DashboardView(selectedItem: .constant(nil))
                .preferredColorScheme(.dark)
            DashboardView(viewModel: RootViewModel(dashboard: DashboardViewModel(with: [
                DashboardItem(with: .customer, subtitle: "Outage: Maps Routing & Navigation", iconColor: .error, subtitleColor: .error),
                DashboardItem(with: .developer, subtitle: "3 Recent Issues", iconColor: .warning, subtitleColor: .warningText)
            ])), selectedItem: .constant(nil))
        }
    }
}
#endif
