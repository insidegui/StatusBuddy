//
//  MenuViewModel.swift
//  StatusUI
//
//  Created by Guilherme Rambo on 29/06/21.
//  Copyright © 2021 Guilherme Rambo. All rights reserved.
//

import Foundation

public final class MenuViewModel: ObservableObject {
    
    @Published private(set) var dashboard: DashboardViewModel
    @Published public var selectedDashboardItem: DashboardItem?
    
    public init() {
        self.dashboard = DashboardViewModel()
    }
    
}
