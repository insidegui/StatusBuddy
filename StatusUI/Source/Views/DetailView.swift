//
//  DetailView.swift
//  StatusBuddyNewUIPrototype
//
//  Created by Guilherme Rambo on 28/06/21.
//

import SwiftUI

struct DetailView: View {
    @StateObject var viewModel = DetailViewModel(with: [
        .activeIssuesPreview,
        .recentIssuesPreview
    ], in: .developer)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(viewModel.scope.title)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .padding([.top, .leading])
                .padding(.leading, 6)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(viewModel.groups) { group in
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
        DetailView()
    }
}
#endif
