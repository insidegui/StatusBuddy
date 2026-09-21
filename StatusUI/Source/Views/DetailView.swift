//
//  DetailView.swift
//  StatusBuddyNewUIPrototype
//
//  Created by Guilherme Rambo on 28/06/21.
//

import SwiftUI

struct DetailView: View {
    @ObservedObject var viewModel: RootViewModel
    
    let scope: ServiceScope
    let groups: [DetailGroup]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            DetailHeader(title: scope.title) {
                viewModel.selectedDashboardItem = nil
            }

            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(groups) { group in
                        DetailGroupView(group)
                    }
                }
                .padding()
            }
        }
    }
}

private struct DetailHeader: View {
    let title: String
    let goBack: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            Button(action: goBack) {
                Label("Back", systemImage: "chevron.backward")
                    .labelStyle(.iconOnly)
            }
            .buttonStyle(.bordered)
            .buttonBorderShape(.circle)
            .keyboardShortcut("[", modifiers: .command)
            .help("Back")

            Text(title)
                .font(.system(.headline, design: .rounded))
            Spacer(minLength: 0)
        }
        .padding([.top, .horizontal], 16)
    }
}

#if DEBUG
struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        DetailView(viewModel: RootViewModel(), scope: .developer, groups: [
            .activeIssuesPreview,
            .recentIssuesPreview
        ])
        .environmentObject(NotificationManager())
        .frame(width: RootView.minWidth, height: 400)
        .windowChrome()
    }
}
#endif
