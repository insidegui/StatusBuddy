//
//  AppleStatusChecker.swift
//  StatusCore
//
//  Created by Guilherme Rambo on 11/02/20.
//  Copyright © 2020 Guilherme Rambo. All rights reserved.
//

import Foundation
import JavaScriptCore

public actor AppleStatusChecker: StatusChecker {
    
    public enum ResponseFormat: Hashable {
        case JSON
        case JSONCallback
    }
    
    enum ResponseHandler {
        case JSON
        case JSONCallback(JSContext)
    }

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

    public func check() async throws -> StatusResponse {
        var lastError: Error?

        for _ in 0..<4 {
            do {
                let (data, _) = try await session.data(from: currentURL)

                if UserDefaults.standard.bool(forKey: "SBSimulateNetworkingError") {
                    throw NSError(domain: "StatusBuddy", code: -1, userInfo: [NSLocalizedFailureReasonErrorKey: "Simulated networking error."])
                }

                return try decoder.decode(StatusResponse.self, from: responseHandler.apply(to: data))
            } catch is CancellationError {
                throw CancellationError()
            } catch {
                guard !Task.isCancelled else { throw CancellationError() }
                lastError = error
            }
        }

        throw lastError ?? CocoaError(.fileReadUnknown)
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
