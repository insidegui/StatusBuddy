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
        print(service.eventMessage)
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(service.serviceName)
                    .font(.system(size: 12.5))
                    .foregroundColor(Color(.textColor))

                if !service.events.isEmpty {
                    Text(service.eventMessage)
                        .foregroundColor(Color(.secondaryLabelColor))
                        .font(.system(size: 11))
                        .fixedSize(horizontal: false, vertical: true)
                    Text(service.eventStartDate)
                        .foregroundColor(Color(.secondaryLabelColor))
                        .font(.system(size: 11))
                    Text(service.eventEndDate)
                        .foregroundColor(Color(.secondaryLabelColor))
                        .font(.system(size: 11))
                }
            }.padding([.top, .bottom], (service.events.isEmpty ? 4 : 8))
            Spacer()
            Circle()
                .frame(width: 10, height: 10, alignment: .center)
                .foregroundColor(service.statusColor)
        }
    }
}
