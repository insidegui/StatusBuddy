//
//  StatusResponse.swift
//  StatusCore
//
//  Created by Guilherme Rambo on 11/02/20.
//  Copyright © 2020 Guilherme Rambo. All rights reserved.
//

import Foundation

public struct StatusResponse: Hashable, Codable {
    public let services: [Service]
}
