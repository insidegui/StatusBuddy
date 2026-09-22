import SwiftUI

enum ServiceCategory: String, CaseIterable, Identifiable {
    case all, customer, developer

    var id: Self { self }

    var title: LocalizedStringResource {
        switch self {
        case .all: LocalizedStringResource("All", bundle: .atURL(Bundle.statusUI.bundleURL))
        case .customer: LocalizedStringResource("Customer", bundle: .atURL(Bundle.statusUI.bundleURL))
        case .developer: LocalizedStringResource("Developer", bundle: .atURL(Bundle.statusUI.bundleURL))
        }
    }

    var scope: ServiceScope? {
        switch self {
        case .all: nil
        case .customer: .customer
        case .developer: .developer
        }
    }
}

struct ServiceOverview {
    enum Kind: String, CaseIterable, Identifiable {
        case active = "ONGOING"
        case scheduled = "SCHEDULED"
        case resolved = "RECENT"
        case operational = "OPERATIONAL"

        var id: Self { self }

        var title: LocalizedStringResource {
            switch self {
            case .active: LocalizedStringResource("Active issues", bundle: .atURL(Bundle.statusUI.bundleURL))
            case .scheduled: LocalizedStringResource("Upcoming maintenance", bundle: .atURL(Bundle.statusUI.bundleURL))
            case .resolved: LocalizedStringResource("Recently resolved", bundle: .atURL(Bundle.statusUI.bundleURL))
            case .operational: LocalizedStringResource("Operational services", bundle: .atURL(Bundle.statusUI.bundleURL))
            }
        }

        var status: LocalizedStringResource {
            switch self {
            case .active: LocalizedStringResource("Issue ongoing", bundle: .atURL(Bundle.statusUI.bundleURL))
            case .scheduled: LocalizedStringResource("Scheduled maintenance", bundle: .atURL(Bundle.statusUI.bundleURL))
            case .resolved: LocalizedStringResource("Resolved", bundle: .atURL(Bundle.statusUI.bundleURL))
            case .operational: LocalizedStringResource("Operational", bundle: .atURL(Bundle.statusUI.bundleURL))
            }
        }

        var symbol: String {
            switch self {
            case .active: "exclamationmark.circle.fill"
            case .scheduled: "calendar"
            case .resolved, .operational: "checkmark.circle.fill"
            }
        }

        var color: Color {
            switch self {
            case .active: .error
            case .scheduled: .scheduledIssue
            case .resolved, .operational: .success
            }
        }
    }

    struct Row: Identifiable {
        struct ID: Hashable {
            let scope: ServiceScope
            let kind: Kind
            let service: String
        }

        let item: DetailGroupItem
        let scope: ServiceScope
        let kind: Kind

        var id: ID { ID(scope: scope, kind: kind, service: item.id) }
    }

    struct Section: Identifiable {
        let kind: Kind
        let rows: [Row]
        var id: Kind { kind }
    }

    let sections: [Section]
    let activeCount: Int

    init(details: [ServiceScope: DetailViewModel], category: ServiceCategory) {
        let groups = details.values
            .filter { category.scope == nil || $0.scope == category.scope }
            .flatMap(\.groups)
        sections = Kind.allCases.compactMap { kind in
            let rows = groups.filter { $0.id == kind.rawValue }.flatMap { group in
                group.items.map { Row(item: $0, scope: group.scope, kind: kind) }
            }.sorted {
                let comparison = $0.item.title.localizedStandardCompare($1.item.title)
                return comparison == .orderedSame ? $0.scope.order < $1.scope.order : comparison == .orderedAscending
            }
            return rows.isEmpty ? nil : Section(kind: kind, rows: rows)
        }
        activeCount = sections.first { $0.kind == .active }?.rows.count ?? 0
    }
}
