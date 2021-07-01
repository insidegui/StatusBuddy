import XCTest
@testable import StatusCore
@testable import StatusUI

final class DetailViewModelTests: XCTestCase {
    
    func testGeneratingCustomerDetailViewModelWithThreeOngoingIssues() throws {
        let response = try StatusResponse.customerThreeOngoingIssues()
        
        let viewModel = DetailViewModel(with: response, in: .customer)
        
        XCTAssertEqual(viewModel.groups.count, 2)
        XCTAssertEqual(viewModel.groups[0].id, "ONGOING")
        XCTAssertEqual(viewModel.groups[0].items.count, 3)
        XCTAssertEqual(viewModel.groups[1].id, "OPERATIONAL")
        XCTAssertEqual(viewModel.groups[1].items.count, 62)
    }
    
    func testGeneratingCustomerDetailViewModelWithThreeRecentIssues() throws {
        let response = try StatusResponse.customerThreeResolvedIssues()
        
        let viewModel = DetailViewModel(with: response, in: .customer)
        
        XCTAssertEqual(viewModel.groups.count, 2)
        XCTAssertEqual(viewModel.groups[0].id, "RECENT")
        XCTAssertEqual(viewModel.groups[0].items.count, 3)
        XCTAssertEqual(viewModel.groups[1].id, "OPERATIONAL")
        XCTAssertEqual(viewModel.groups[1].items.count, 62)
    }
    
}
