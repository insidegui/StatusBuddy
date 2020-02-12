//
//  ServiceStatusView.swift
//  StatusBuddy
//
//  Created by Guilherme Rambo on 11/02/20.
//  Copyright © 2020 Guilherme Rambo. All rights reserved.
//

import SwiftUI
import StatusCore

struct ServiceStatusView: View {
    let service: Service

    init(_ service: Service) {
        self.service = service
    }
    
    var body: some View {
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
}
