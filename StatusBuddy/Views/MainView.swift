//
//  MainView.swift
//  StatusBuddy
//
//  Created by Guilherme Rambo on 11/02/20.
//  Copyright © 2020 Guilherme Rambo. All rights reserved.
//

import SwiftUI
import StatusCore

struct MainView: View {
    @EnvironmentObject var dataSource: StatusProvider
    @EnvironmentObject var preferences: Preferences

    private var sortedServices: [Service] {
        let allServices = dataSource.consumerServices + dataSource.developerServices
        return allServices
            .filter({ searchTerm.isEmpty ? true : $0.serviceName.lowercased().contains(searchTerm.lowercased()) })
            .sorted(by: { $0.serviceName < $1.serviceName })
            .sorted(by: { $0.events.count > $1.events.count })
    }

    @State private var searchTerm = ""

    var body: some View {
        VStack(spacing: 0) {
            if dataSource.isPerformingInitialLoad {
                LoadingView(spinning: true)
            } else {
                HStack {
                    TextField("Search", text: $searchTerm)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    PreferencesView()
                }.padding(EdgeInsets(top: 10, leading: 14, bottom: 4, trailing: 14))

                Rectangle().frame(height: 1)
                    .foregroundColor(Color(.separatorColor))
                    .padding([.top, .bottom], 6)

                List {
                    ForEach(sortedServices) { service in
                        ServiceStatusView(service)
                    }
                }.listStyle(SidebarListStyle())
            }
        }
    }
}
