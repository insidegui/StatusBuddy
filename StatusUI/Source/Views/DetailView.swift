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
            Text(scope.title)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .padding([.top, .leading])
                .padding(.leading, 6)
                .foregroundColor(.primaryText)
            
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

#if DEBUG
struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        DetailView(viewModel: RootViewModel(), scope: .developer, groups: [
            .activeIssuesPreview,
            .recentIssuesPreview
        ])
    }
}
#endif
