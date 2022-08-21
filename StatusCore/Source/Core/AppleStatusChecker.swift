//
//  AppleStatusChecker.swift
//  StatusCore
//
//  Created by Guilherme Rambo on 11/02/20.
//  Copyright © 2020 Guilherme Rambo. All rights reserved.
//

import Foundation
import Combine
import JavaScriptCore
import os.log

public final class AppleStatusChecker: StatusChecker {
    
    public enum ResponseFormat: Hashable {
        case JSON
        case JSONCallback
    }
    
    enum ResponseHandler {
        case JSON
        case JSONCallback(JSContext)
    }

    private let log = OSLog(subsystem: StatusCore.subsystemName, category: String(describing: AppleStatusChecker.self))

    let endpoint: URL
    let format: ResponseFormat
    private let responseHandler: ResponseHandler

    public init(endpoint: URL, format: ResponseFormat) {
        self.endpoint = endpoint
        self.format = format
        
        switch format {
        case .JSON:
            self.responseHandler = .JSON
        case .JSONCallback:
            self.responseHandler = .JSONCallback(JSContext())
        }
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
        let handler = self.responseHandler
        
        return session.dataTaskPublisher(for: currentURL)
            .tryMap({
                if UserDefaults.standard.bool(forKey: "SBSimulateNetworkingError") {
                    throw NSError(domain: "StatusBuddy", code: -1, userInfo: [NSLocalizedFailureReasonErrorKey: "Simulated networking error."])
                } else {
                    return try handler.apply(to: $0.data)
                }
            })
            .decode(type: StatusResponse.self, decoder: decoder)
            .retry(3)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    

}

private extension AppleStatusChecker.ResponseHandler {
    
    func apply(to data: Data) throws -> Data {
        switch self {
        case .JSON:
            return data
        case .JSONCallback(let context):
            return try processJavascript(data, using: context)
        }
    }
    
    private func processJavascript(_ input: Data, using context: JSContext) throws -> Data {
        context.evaluateScript("""
        function jsonCallback(json) {
            return JSON.stringify(json);
        }
        """)
        
        guard let output = context.evaluateScript(String(decoding: input, as: UTF8.self)) else {
            throw CocoaError(.coderValueNotFound)
        }
        
        guard output.isString else { throw CocoaError(.coderValueNotFound) }
        
        return Data(output.toString().utf8)
    }
    
}
