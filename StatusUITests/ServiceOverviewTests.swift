import XCTest
@testable import StatusUI

final class ServiceOverviewTests: XCTestCase {
    func testAllCategoriesKeepsScopeAndStatusInRowIdentity() {
        let overview = ServiceOverview(details: [
            .customer: details(scope: .customer, kinds: [.active]),
            .developer: details(scope: .developer, kinds: [.active, .scheduled])
        ], category: .all)

        let rows = overview.sections.flatMap(\.rows)
        XCTAssertEqual(overview.activeCount, 2)
        XCTAssertEqual(rows.count, 3)
        XCTAssertEqual(Set(rows.map(\.id)).count, 3)
        XCTAssertEqual(Set(rows.map(\.scope)), [.customer, .developer])
    }

    func testCategoryFiltersCountsAndOperationalServices() {
        let overview = ServiceOverview(details: [
            .customer: details(scope: .customer, kinds: [.active, .operational]),
            .developer: details(scope: .developer, kinds: [.scheduled, .operational])
        ], category: .developer)

        XCTAssertEqual(overview.activeCount, 0)
        XCTAssertEqual(overview.sections.map(\.kind), [.scheduled, .operational])
        XCTAssertTrue(overview.sections.flatMap(\.rows).allSatisfy { $0.scope == .developer })
    }

    func testSectionsPrioritizeActiveIssuesAndOmitEmptyGroups() {
        let overview = ServiceOverview(details: [
            .developer: details(scope: .developer, kinds: [.operational, .resolved, .scheduled, .active])
        ], category: .all)

        XCTAssertEqual(overview.sections.map(\.kind), [.active, .scheduled, .resolved, .operational])
        XCTAssertTrue(ServiceOverview(details: [:], category: .all).sections.isEmpty)
    }

    func testRowsSortByNameIndependentOfFeedOrder() {
        let group = DetailGroup(
            id: "ONGOING", scope: .developer, iconName: "", title: "", accentColor: .red,
            supportsNotifications: true,
            items: ["TestFlight", "App Store Connect"].map {
                DetailGroupItem(id: $0, title: $0, subtitle: nil, formattedResolutionTime: nil)
            }
        )
        let overview = ServiceOverview(details: [
            .developer: DetailViewModel(with: [group], in: .developer)
        ], category: .all)

        XCTAssertEqual(overview.sections.first?.rows.map(\.item.title), ["App Store Connect", "TestFlight"])
    }

    private func details(scope: ServiceScope, kinds: [ServiceOverview.Kind]) -> DetailViewModel {
        DetailViewModel(with: kinds.map { kind in
            DetailGroup(
                id: kind.rawValue, scope: scope, iconName: "", title: "", accentColor: .red,
                supportsNotifications: kind == .active,
                items: [DetailGroupItem(id: "Shared service", title: "Shared service", subtitle: nil, formattedResolutionTime: nil)]
            )
        }, in: scope)
    }
}
