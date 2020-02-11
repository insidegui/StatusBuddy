//
//  StatusChecker.swift
//  StatusCore
//
//  Created by Guilherme Rambo on 11/02/20.
//  Copyright © 2020 Guilherme Rambo. All rights reserved.
//

import Foundation
import Combine

public final class StatusChecker: ObservableObject {

    let endpoint: URL
    public var autoCheckInterval: TimeInterval?

    public init(endpoint: URL, autoCheckInterval: TimeInterval? = 600) {
        self.endpoint = endpoint
        self.autoCheckInterval = autoCheckInterval

        startAutoCheckTimer()
        check()
    }

    @Published public private(set) var currentStatus: StatusResponse?

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

    @discardableResult public func check() -> Cancellable {
        inFlightCheck?.cancel()
        inFlightCheck = nil
        
        let cancellable = session.dataTaskPublisher(for: endpoint)
            .map({ $0.data.demanglingAppleDeveloperStatusResponseIfNeeded })
            .decode(type: StatusResponse.self, decoder: decoder)
            .retry(3)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in }, receiveValue: { value in
                self.currentStatus = value
            })

        inFlightCheck = cancellable

        return cancellable
    }

    private var inFlightCheck: Cancellable?
    private var autoCheckTimer: Timer?

    private func startAutoCheckTimer() {
        autoCheckTimer?.invalidate()

        guard let interval = autoCheckInterval else { return }

        autoCheckTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true, block: { [weak self ]_ in
            guard let self = self else { return }

            self.inFlightCheck?.cancel()
            self.inFlightCheck = self.check()
        })
        autoCheckTimer?.tolerance = interval / 2
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
