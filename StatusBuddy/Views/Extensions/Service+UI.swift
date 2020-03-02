//
//  Service+UI.swift
//  StatusBuddy
//
//  Created by Guilherme Rambo on 11/02/20.
//  Copyright © 2020 Guilherme Rambo. All rights reserved.
//

import Foundation
import SwiftUI
import StatusCore

extension Service: Identifiable {
    public typealias ID = String
    public var id: String { serviceName }
}

extension Service {
    var statusColor: Color {
        guard !events.isEmpty else { return .green }

        if events.last?.epochEndDate == nil {
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
        guard let event = events.last else { return "" }

        return event.message
    }

    var eventStartDate: String {
        guard let event = events.last else { return "" }

        if let startDate = event.epochStartDate {
            return "Start: \(Self.dateFormatter.string(from: startDate))"
        }

        return ""
    }

    var eventEndDate: String {
        guard let event = events.last else { return "" }

        if let endDate = event.epochEndDate {
            return "End: \(Self.dateFormatter.string(from: endDate))"
        }

        return "No end date given."
    }
}
