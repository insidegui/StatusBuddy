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
    
    struct Metrics {
        static let verticalMargin: CGFloat = 10
        static let horizontalPadding: CGFloat = 14
        static let statusViewInsets = EdgeInsets(top: 0, leading: Metrics.horizontalPadding, bottom: 0, trailing: Metrics.horizontalPadding)
        static let headerInsets = EdgeInsets(top: Metrics.verticalMargin, leading: Metrics.horizontalPadding, bottom: 4, trailing: Metrics.horizontalPadding)
    }

    var body: some View {
        VStack(spacing: 0) {
            if dataSource.isPerformingInitialLoad {
                LoadingView(spinning: true)
            } else {
                HStack(spacing: 0) {
                    TextField("Search", text: $searchTerm)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    PreferencesView()
                        .frame(width: 16, height: 16)
                }
                .padding(Metrics.headerInsets)

                Rectangle().frame(height: 1)
                    .foregroundColor(Color(.separatorColor))
                    .padding([.top, .bottom], 6)

                ScrollView {
                    VStack {
                        ForEach(sortedServices) { service in
                            ServiceStatusView(service)
                                .padding(Metrics.statusViewInsets)
                        }
                    }
                    .padding(.bottom, Metrics.verticalMargin)
                }
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
}
