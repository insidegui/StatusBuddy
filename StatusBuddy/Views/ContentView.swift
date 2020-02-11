//
//  ContentView.swift
//  StatusBuddy
//
//  Created by Guilherme Rambo on 11/02/20.
//  Copyright © 2020 Guilherme Rambo. All rights reserved.
//

import SwiftUI
import StatusCore

struct ContentView: View {
    @EnvironmentObject var dataSource: StatusProvider

    private var sortedServices: [Service] {
        let allServices = dataSource.consumerServices + dataSource.developerServices
        return allServices
            .filter({ searchTerm.isEmpty ? true : $0.serviceName.lowercased().contains(searchTerm) })
            .sorted(by: { $0.serviceName < $1.serviceName })
            .sorted(by: { $0.events.count > $1.events.count })
    }

    @State private var searchTerm = ""

    var body: some View {
        VStack(spacing: 0) {
            TextField("Search", text: $searchTerm)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(EdgeInsets(top: 10, leading: 14, bottom: 4, trailing: 14))

            Rectangle().frame(height: 1)
                .foregroundColor(Color(.separatorColor))
                .padding([.top, .bottom], 6)

            List {
                ForEach(sortedServices) { service in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(service.serviceName)

                            if !service.events.isEmpty {
                                Text(service.eventMessage)
                                    .foregroundColor(Color(.secondaryLabelColor))
                                    .font(.system(size: 11))
                                    .lineLimit(2)
                            }
                        }.padding([.top, .bottom], 4)
                        Spacer()
                        Circle()
                            .frame(width: 10, height: 10, alignment: .center)
                            .foregroundColor(service.statusColor)
                    }
                }
            }.listStyle(SidebarListStyle())
        }
    }
}

extension Service {
    var statusColor: Color {
        guard !events.isEmpty else { return .green }

        if events[0].epochEndDate == nil {
            return .red
        } else {
            return .yellow
        }
    }

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .short
        f.timeStyle = .short
        return f
    }()

    var eventMessage: String {
        guard let event = events.first else { return "" }

        var suffix = ""
        if let endDate = event.epochEndDate {
            suffix = "\n(Ended \(Self.dateFormatter.string(from: endDate)))"
        }

        return event.message + suffix
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(StatusProvider())
    }
}

extension Service: Identifiable {
    public typealias ID = String
    public var id: String { serviceName }
}
