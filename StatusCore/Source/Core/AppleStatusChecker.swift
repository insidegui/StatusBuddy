//
//  AppleStatusChecker.swift
//  StatusCore
//
//  Created by Guilherme Rambo on 11/02/20.
//  Copyright © 2020 Guilherme Rambo. All rights reserved.
//

import Foundation
import Combine
import os.log

public final class AppleStatusChecker: StatusChecker {

    private let log = OSLog(subsystem: StatusCore.subsystemName, category: String(describing: AppleStatusChecker.self))

    let endpoint: URL

    public init(endpoint: URL) {
        self.endpoint = endpoint
    }

    private var currentURL: URL {
        guard var components = URLComponents(url: endpoint, resolvingAgainstBaseURL: false) else {
            return endpoint
        }

        // Copying the same behavior from Apple's web UI.
        var queryItems: [URLQueryItem] = components.queryItems ?? []
        queryItems.append(URLQueryItem(name: "_", value: String(Date().timeIntervalSince1970)))

        components.queryItems = queryItems

        return components.url ?? endpoint
    }

    private lazy var session: URLSession = {
        let config = URLSessionConfiguration.default
        config.waitsForConnectivity = true
        config.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        return URLSession(configuration: config)
    }()

    private lazy var decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .millisecondsSince1970
        return decoder
    }()

    public func check() -> StatusResponsePublisher {
        session.dataTaskPublisher(for: currentURL)
            .map({ $0.data.demanglingAppleDeveloperStatusResponseIfNeeded })
            .decode(type: StatusResponse.self, decoder: decoder)
            .retry(3)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

}

extension Data {
    /// Apple's response for the developer portal's status is a json callback, which
    /// starts with `jsonCallback(` and ends with `);`.
    /// This returns the data, removing the extra bits at the start and end,
    /// turning it into valid JSON.
    var demanglingAppleDeveloperStatusResponseIfNeeded: Data {
        guard count >= 15 else { return self }
        guard first != 123 else { return self }
        return self[13..<(count-2)]
    }
}
