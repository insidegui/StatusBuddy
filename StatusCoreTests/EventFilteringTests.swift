import XCTest
@testable import StatusCore

final class EventFilteringTests: XCTestCase {

    func testFilteringRecentDeveloperEvents() throws {
        let response = try StatusResponse.developerOneResolvedIssue()
        
        XCTAssertEqual(response.services.filter({ $0.hasRecentEvents }).count, 1)
        XCTAssertEqual(response.services.filter({ $0.hasActiveEvents }).count, 0)
    }
    
    func testFilteringRecentConsumerEvents() throws {
        let response = try StatusResponse.consumerThreeResolvedIssues()
        
        XCTAssertEqual(response.services.filter({ $0.hasRecentEvents }).count, 3)
        XCTAssertEqual(response.services.filter({ $0.hasActiveEvents }).count, 0)
    }
    
    func testFilteringMostRecentConsumerEvent() throws {
        let response = try StatusResponse.consumerThreeResolvedIssues()
        let targetService = response.services.first(where: { $0.serviceName == "Apple Business Manager" })!
        
        XCTAssertEqual(targetService.latestEvent?.message, "Apple Business Manager was temporarily unavailable during system maintenance.")
    }
    
    func testFilteringActiveConsumerEvents() throws {
        let response = try StatusResponse.consumerOneOngoingIssue()
        
        XCTAssertEqual(response.services.filter(\.hasActiveEvents).count, 1)
        XCTAssertEqual(response.services.filter(\.hasActiveEvents).first?.latestEvent?.message, "Users may be experiencing intermittent issues with this service.")
    }
    
    func testFilteringActiveDeveloperEvents() throws {
        let response = try StatusResponse.developerOneOngoingIssue()
        
        XCTAssertEqual(response.services.filter(\.hasActiveEvents).count, 1)
        XCTAssertEqual(response.services.filter(\.hasActiveEvents).first?.latestEvent?.message, "Due to maintenance, some services are unavailable.")
    }
}

extension Bundle {
    static let test = Bundle(for: EventFilteringTests.self)
    
    func load<T: Decodable>(_ type: T.Type, from filename: String) throws -> T {
        guard let fileURL = url(forResource: filename, withExtension: "json") else { throw NSError() }
        
        let data = try Data(contentsOf: fileURL)
        
        return try JSONDecoder().decode(type, from: data)
    }
}

extension StatusResponse {
    static func developerOneResolvedIssue() throws -> StatusResponse {
        try Bundle.test.load(StatusResponse.self, from: "developer-one-resolved-issue")
    }
    
    static func consumerThreeResolvedIssues() throws -> StatusResponse {
        try Bundle.test.load(StatusResponse.self, from: "consumer-three-resolved-issues")
    }
    
    static func consumerOneOngoingIssue() throws -> StatusResponse {
        try Bundle.test.load(StatusResponse.self, from: "consumer-one-ongoing-issue")
    }
    
    static func developerOneOngoingIssue() throws -> StatusResponse {
        try Bundle.test.load(StatusResponse.self, from: "developer-one-ongoing-issue")
    }
}
