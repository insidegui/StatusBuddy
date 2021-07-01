//
//  DetailViewModel.swift
//  StatusBuddyNewUIPrototype
//
//  Created by Guilherme Rambo on 28/06/21.
//

import SwiftUI
import StatusCore

final class DetailViewModel: ObservableObject {
    let scope: ServiceScope
    
    @Published private(set) var groups: [DetailGroup]
    
    init(with groups: [DetailGroup], in scope: ServiceScope) {
        self.scope = scope
        self.groups = groups
    }
}

extension DetailViewModel {
    convenience init(with response: StatusResponse, in scope: ServiceScope) {
        self.init(with: DetailGroup.generateGroups(with: response, in: scope), in: scope)
    }
}
