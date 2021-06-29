//
//  ServiceScope.swift
//  StatusBuddyNewUIPrototype
//
//  Created by Guilherme Rambo on 28/06/21.
//

import Foundation

struct ServiceScope: Hashable, Identifiable {
    let id: String
    let iconName: String
    let title: String
}

extension ServiceScope {
    static let developer = ServiceScope(
        id: "DEVELOPER",
        iconName: "hammer.fill",
        title: "Developer Services"
    )
    
    static let customer = ServiceScope(
        id: "CUSTOMER",
        iconName: "person.fill",
        title: "Customer Services"
    )
}
