import Foundation
@testable import StatusCore

private final class _StubForTestBundleInit { }

extension Bundle {
    static let test = Bundle(for: _StubForTestBundleInit.self)
    
    func load<T: Decodable>(_ type: T.Type, from filename: String) throws -> T {
        guard let fileURL = url(forResource: filename, withExtension: "json") else {
            assertionFailure("Missing file \(filename).json")
            throw NSError(domain: "", code: 1, userInfo: nil)
        }
        
        let data = try Data(contentsOf: fileURL)
        
        return try JSONDecoder().decode(type, from: data)
    }
}

extension StatusResponse {
    static func developerOneResolvedIssue() throws -> StatusResponse {
        try Bundle.test.load(StatusResponse.self, from: "developer-one-resolved-issue")
    }
    
    static func customerThreeResolvedIssues() throws -> StatusResponse {
        try Bundle.test.load(StatusResponse.self, from: "customer-three-resolved-issues")
    }
    
    static func customerOneOngoingIssue() throws -> StatusResponse {
        try Bundle.test.load(StatusResponse.self, from: "customer-one-ongoing-issue")
    }
    
    static func customerThreeOngoingIssues() throws -> StatusResponse {
        try Bundle.test.load(StatusResponse.self, from: "customer-three-ongoing-issues")
    }
    
    static func developerOneOngoingIssue() throws -> StatusResponse {
        try Bundle.test.load(StatusResponse.self, from: "developer-one-ongoing-issue")
    }
    
    static func customerNoIssues() throws -> StatusResponse {
        try Bundle.test.load(StatusResponse.self, from: "customer-no-issues")
    }
    
    static func developerNoIssues() throws -> StatusResponse {
        try Bundle.test.load(StatusResponse.self, from: "developer-no-issues")
    }
}
