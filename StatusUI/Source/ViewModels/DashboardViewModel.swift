//
//  DashboardViewModel.swift
//  StatusBuddyNewUIPrototype
//
//  Created by Guilherme Rambo on 28/06/21.
//

import SwiftUI

final class DashboardViewModel: ObservableObject {
    @Published private(set) var items: [DashboardItem]
    
    init(with items: [DashboardItem] = [
        DashboardItem(with: .customer),
        DashboardItem(with: .developer)
    ]) {
        self.items = items
    }
}
