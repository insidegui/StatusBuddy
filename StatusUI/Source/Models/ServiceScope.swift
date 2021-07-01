//
//  ServiceScope.swift
//  StatusBuddyNewUIPrototype
//
//  Created by Guilherme Rambo on 28/06/21.
//

import Foundation

public struct ServiceScope: Hashable, Identifiable {
    let order: Int
    public let id: String
    let iconName: String
    let title: String
}

public extension ServiceScope {
    static let developer = ServiceScope(
        order: 1,
        id: "DEVELOPER",
        iconName: "hammer.fill",
        title: "Developer Services"
    )
    
    static let customer = ServiceScope(
        order: 0,
        id: "CUSTOMER",
        iconName: "person.fill",
        title: "Customer Services"
    )
}
