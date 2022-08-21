//
//  StatusChecker.swift
//  StatusCore
//
//  Created by Guilherme Rambo on 29/06/21.
//  Copyright © 2021 Guilherme Rambo. All rights reserved.
//

import Foundation
import Combine

public typealias StatusResponsePublisher = AnyPublisher<StatusResponse, Error>

public protocol StatusChecker {
    func check() -> StatusResponsePublisher
}
