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

    @State private var circleHover: Bool = false

    init(_ service: Service) {
        self.service = service
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
                }
            }.padding([.top, .bottom], (service.events.isEmpty ? 4.0 : 8.0))
            Spacer()
            Circle()
                .frame(width: 10, height: 10, alignment: .center)
                .foregroundColor(service.statusColor)
                .onHover(perform: { _ in
                    if !self.service.events.isEmpty {
                        self.circleHover.toggle()
                    }
                })
                .popover(isPresented: $circleHover, content: {
                    VStack(alignment: .trailing, spacing: 6) {
                        Text(self.service.eventStartDate)
                        Text(self.service.eventEndDate)
                    }
                    .foregroundColor(Color(.secondaryLabelColor))
                    .font(.system(size: 11))
                    .padding()
                })
        }
    }
}
