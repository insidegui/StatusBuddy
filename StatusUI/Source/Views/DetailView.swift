//
//  DetailView.swift
//  StatusBuddyNewUIPrototype
//
//  Created by Guilherme Rambo on 28/06/21.
//

import SwiftUI

struct DetailView: View {
    let viewModel: RootViewModel
    
    let scope: ServiceScope
    let groups: [DetailGroup]
    
    var body: some View {
        ScrollView(.vertical) {
            LazyVStack(alignment: .leading, spacing: 8, pinnedViews: .sectionHeaders) {
                ForEach(groups) { group in
                    DetailGroupView(group)
                }
            }
        }
    }
}

#if DEBUG
struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        DetailView(viewModel: RootViewModel(), scope: .developer, groups: [
            .activeIssuesPreview,
            .recentIssuesPreview
        ])
        .environment(NotificationManager())
        .frame(width: RootView.minWidth, height: 400)
        .windowChrome()
    }
}
#endif
