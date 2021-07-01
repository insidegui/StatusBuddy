import XCTest
@testable import StatusCore
@testable import StatusUI

final class DashboardViewModelTests: XCTestCase {

    func testGeneratingDashboardWithNoIssues() throws {
        let customerResponse = try StatusResponse.customerNoIssues()
        let developerResponse = try StatusResponse.developerNoIssues()
        
        let viewModel = DashboardViewModel(with: [
            .customer: customerResponse,
            .developer: developerResponse
        ])
        
        XCTAssertEqual(viewModel.items.count, 2)
        
        XCTAssertEqual(viewModel.items[0].title, "Customer Services")
        XCTAssertEqual(viewModel.items[0].subtitle, "All Systems Operational")
        XCTAssertEqual(viewModel.items[0].iconColor, .accent)
        XCTAssertEqual(viewModel.items[0].subtitleColor, .secondaryText)
        
        XCTAssertEqual(viewModel.items[1].title, "Developer Services")
        XCTAssertEqual(viewModel.items[1].subtitle, "All Systems Operational")
        XCTAssertEqual(viewModel.items[1].iconColor, .accent)
        XCTAssertEqual(viewModel.items[1].subtitleColor, .secondaryText)
    }

    func testGeneratingDashboardWithRecentIssues() throws {
        let customerResponse = try StatusResponse.customerThreeResolvedIssues()
        let developerResponse = try StatusResponse.developerOneResolvedIssue()
        
        let viewModel = DashboardViewModel(with: [
            .customer: customerResponse,
            .developer: developerResponse
        ])
        
        XCTAssertEqual(viewModel.items.count, 2)
        
        XCTAssertEqual(viewModel.items[0].title, "Customer Services")
        XCTAssertEqual(viewModel.items[0].subtitle, "3 Recent Issues")
        XCTAssertEqual(viewModel.items[0].iconColor, .warning)
        XCTAssertEqual(viewModel.items[0].subtitleColor, .warningText)
        
        XCTAssertEqual(viewModel.items[1].title, "Developer Services")
        XCTAssertEqual(viewModel.items[1].subtitle, "Recent Issue: Developer ID Notary Service")
        XCTAssertEqual(viewModel.items[1].iconColor, .warning)
        XCTAssertEqual(viewModel.items[1].subtitleColor, .warningText)
    }
    
    func testGeneratingDashboardWithOngoingIssues() throws {
        let customerResponse = try StatusResponse.customerThreeOngoingIssues()
        let developerResponse = try StatusResponse.developerOneOngoingIssue()
        
        let viewModel = DashboardViewModel(with: [
            .customer: customerResponse,
            .developer: developerResponse
        ])
        
        XCTAssertEqual(viewModel.items.count, 2)
        
        XCTAssertEqual(viewModel.items[0].title, "Customer Services")
        XCTAssertEqual(viewModel.items[0].subtitle, "3 Ongoing Issues")
        XCTAssertEqual(viewModel.items[0].iconColor, .error)
        XCTAssertEqual(viewModel.items[0].subtitleColor, .error)
        
        XCTAssertEqual(viewModel.items[1].title, "Developer Services")
        XCTAssertEqual(viewModel.items[1].subtitle, "Outage: Videos")
        XCTAssertEqual(viewModel.items[1].iconColor, .error)
        XCTAssertEqual(viewModel.items[1].subtitleColor, .error)
    }
    
}
