//
//  StatusChecker.swift
//  StatusCore
//
//  Created by Guilherme Rambo on 29/06/21.
//  Copyright © 2021 Guilherme Rambo. All rights reserved.
//

import Foundation
import Combine

public typealias StatusCheckCompletionHandler = (Result<StatusResponse, Error>) -> Void

public protocol StatusChecker {
    var currentStatus: StatusResponse? { get }
    
    @discardableResult func check(with completion: StatusCheckCompletionHandler?) -> Cancellable
    func clear()
}
