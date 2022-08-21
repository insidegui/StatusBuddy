//
//  DashboardViewModel.swift
//  StatusBuddyNewUIPrototype
//
//  Created by Guilherme Rambo on 28/06/21.
//

import SwiftUI
import StatusCore

public struct DashboardViewModel {
    public enum State {
        case loading
        case loaded([DashboardItem])
        case failure(String)
    }
    
    public let state: State
    
    public init(with state: State = .loading) {
        self.state = state
    }
}

extension DashboardViewModel {
    init(with responses: [ServiceScope: StatusResponse]) {
        let items: [DashboardItem] = responses
            .sorted(by: { $0.key.order < $1.key.order })
            .map { DashboardItem(with: $1, in: $0) }
        
        self.init(with: .loaded(items))
    }
}
