//
//  DashboardViewModel.swift
//  StatusBuddyNewUIPrototype
//
//  Created by Guilherme Rambo on 28/06/21.
//

import SwiftUI
import StatusCore

final class DashboardViewModel: ObservableObject {
    @Published private(set) var items: [DashboardItem]
    
    init(with items: [DashboardItem] = [
        DashboardItem(with: .customer),
        DashboardItem(with: .developer)
    ]) {
        self.items = items
    }
}

extension DashboardViewModel {
    convenience init(with responses: [ServiceScope: StatusResponse]) {
        let items: [DashboardItem] = responses
            .sorted(by: { $0.key.order < $1.key.order })
            .map { DashboardItem(with: $1, in: $0) }
        
        self.init(with: items)
    }
}
