//
//  StatusChecker.swift
//  StatusCore
//
//  Created by Guilherme Rambo on 29/06/21.
//  Copyright © 2021 Guilherme Rambo. All rights reserved.
//

import Foundation
public protocol StatusChecker: Sendable {
    func check() async throws -> StatusResponse
}
