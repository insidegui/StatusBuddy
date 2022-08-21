//
//  DetailViewModel.swift
//  StatusBuddyNewUIPrototype
//
//  Created by Guilherme Rambo on 28/06/21.
//

import SwiftUI
import StatusCore

struct DetailViewModel {
    let scope: ServiceScope
    
    let groups: [DetailGroup]
    
    init(with groups: [DetailGroup], in scope: ServiceScope) {
        self.scope = scope
        self.groups = groups
    }
}

extension DetailViewModel {
    init(with response: StatusResponse, in scope: ServiceScope) {
        self.init(with: DetailGroup.generateGroups(with: response, in: scope), in: scope)
    }
}
