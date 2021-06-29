//
//  DashboardView.swift
//  StatusBuddyNewUIPrototype
//
//  Created by Guilherme Rambo on 28/06/21.
//

import SwiftUI

struct DashboardView: View {
    @StateObject var viewModel = DashboardViewModel()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(viewModel.items) { item in
                DashboardItemView(item)
            }
        }
        .padding()
        .background(Color.background)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

#if DEBUG
struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            DashboardView()
            DashboardView()
                .preferredColorScheme(.dark)
            DashboardView(viewModel: DashboardViewModel(with: [
                DashboardItem(with: .customer, subtitle: "Outage: Maps Routing & Navigation", iconColor: .error, subtitleColor: .error),
                DashboardItem(with: .developer, subtitle: "3 Recent Issues", iconColor: .warning, subtitleColor: .warningText)
            ]))
        }
    }
}
#endif
