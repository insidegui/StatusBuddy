//
//  DetailViewModel.swift
//  StatusBuddyNewUIPrototype
//
//  Created by Guilherme Rambo on 28/06/21.
//

import SwiftUI

final class DetailViewModel: ObservableObject {
    let scope: ServiceScope
    
    @Published private(set) var groups: [DetailGroup]
    
    init(with groups: [DetailGroup], in scope: ServiceScope) {
        self.scope = scope
        self.groups = groups
    }
}
