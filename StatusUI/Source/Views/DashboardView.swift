import SwiftUI

struct DashboardView: View {
    static var padding: Double { 16 }

    @State var viewModel: RootViewModel

    private static let enableCategoryPicker = UserDefaults.standard.bool(forKey: "SBEnableCategoryPicker")

    var body: some View {
        DashboardContent(viewModel: viewModel)
        .frame(maxWidth: .infinity)
        .contentMargins(Self.padding, for: .scrollContent)
        .safeAreaInset(edge: .top, spacing: -Self.padding) {
            VStack(spacing: 12) {
                DashboardHeader(viewModel: viewModel)

                if Self.enableCategoryPicker {
                    Picker(selection: $viewModel.category) {
                        ForEach(ServiceCategory.allCases) { category in
                            Text(category.title).tag(category)
                        }
                    } label: {
                        Text("Service category", bundle: .statusUI)
                    }
                    .pickerStyle(.segmented)
                    .labelsHidden()
                }
            }
            .padding([.top, .leading, .trailing], Self.padding)
            .padding(.bottom, Self.padding / 2)
            .variableBlurBackdrop(edge: .top)
        }
        .safeAreaInset(edge: .bottom, spacing: -Self.padding) {
            DashboardFooter(lastUpdated: viewModel.lastUpdated)
                .padding(Self.padding)
                .variableBlurBackdrop(edge: .bottom)
        }
        .compositingGroup()
    }
}

private struct DashboardHeader: View {
    let viewModel: RootViewModel

    var body: some View {
        HStack {
            if let overview = viewModel.overviews[viewModel.category] {
                ServiceStatusSummary(activeCount: overview.activeCount)
            }
            Spacer()
            Button {
                viewModel.refresh()
            } label: {
                Label {
                    Text("Refresh", bundle: .statusUI)
                } icon: {
                    Image(systemName: "arrow.clockwise")
                }
                .labelStyle(.iconOnly)
            }
            .disabled(viewModel.isRefreshing)
            .help(Text("Refresh service status", bundle: .statusUI))
            .keyboardShortcut("r", modifiers: .command)

            Button(action: viewModel.showSettingsMenu) {
                Label {
                    Text("Settings", bundle: .statusUI)
                } icon: {
                    Image(systemName: "gearshape")
                }
                .labelStyle(.iconOnly)
            }
            .help(Text("Settings", bundle: .statusUI))
        }
        .buttonStyle(.glass)
        .buttonBorderShape(.circle)
    }
}

private struct DashboardContent: View {
    let viewModel: RootViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if case .failure = viewModel.dashboard.state {
                    DashboardFailure(hasCachedStatus: viewModel.lastUpdated != nil) {
                        viewModel.refresh()
                    }
                }

                if let overview = viewModel.overviews[viewModel.category] {
                    ServiceOverviewContent(overview: overview, showScope: viewModel.category == .all)
                } else if case .loading = viewModel.dashboard.state {
                    ProgressView {
                        Text("Checking service status…", bundle: .statusUI)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
                }
            }
            .padding(.vertical, 12)
        }
        .id(viewModel.category)
    }
}

private struct DashboardFailure: View {
    let hasCachedStatus: Bool
    let retry: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label {
                Text("Unable to refresh", bundle: .statusUI)
            } icon: {
                Image(systemName: "wifi.exclamationmark")
            }
            .font(.headline)
            Text(hasCachedStatus
                 ? "Showing the last known status. Check your connection and try again."
                 : "Check your connection and try again.", bundle: .statusUI)
                .font(.callout)
                .foregroundStyle(.secondary)
            Button(action: retry) {
                Text("Try Again", bundle: .statusUI)
            }
            .buttonStyle(.bordered)
        }
    }
}

private struct IncidentExpansion {
    var selected: ServiceOverview.Row.ID?

    subscript(row id: ServiceOverview.Row.ID) -> Bool {
        get { selected == id }
        set {
            if newValue {
                selected = id
            } else if selected == id {
                selected = nil
            }
        }
    }
}

private struct ServiceOverviewContent: View {
    let overview: ServiceOverview
    let showScope: Bool
    @State private var expansion = IncidentExpansion()

    var body: some View {
        ForEach(overview.sections) { section in
            ServiceOverviewSection(section: section, showScope: showScope, expansion: $expansion)
        }
    }
}

private struct ServiceStatusSummary: View {
    let activeCount: Int

    var body: some View {
        HStack {
            Image(systemName: activeCount == 0 ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                .foregroundStyle(activeCount == 0 ? Color.success : Color.error)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 4) {
                Group {
                    if activeCount == 0 {
                        Text("All systems operational", bundle: .statusUI)
                    } else {
                        Text("^[\(activeCount) active issue](inflect: true)", bundle: .statusUI)
                    }
                }
            }
        }
        .font(.headline.weight(.medium))
        .accessibilityElement(children: .combine)
    }
}

private struct ServiceOverviewSection: View {
    let section: ServiceOverview.Section
    let showScope: Bool
    @Binding var expansion: IncidentExpansion
    @State private var showsOperationalServices = false

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if section.kind == .operational {
                DisclosureGroup(isExpanded: $showsOperationalServices) {
                    ForEach(section.rows) { row in
                        ServiceRowLabel(row: row, showScope: showScope)
                            .padding(.vertical, 6)
                    }
                } label: {
                    ServiceSectionHeading(kind: section.kind, count: section.rows.count)
                }
                .disclosureGroupStyle(ServiceDisclosureStyle())
            } else {
                ServiceSectionHeading(kind: section.kind, count: section.rows.count)
                    .padding(.bottom, 4)
                ForEach(section.rows) { row in
                    IncidentRow(row: row, showScope: showScope, isExpanded: $expansion[row: row.id])
                }
            }
        }
    }
}

private struct ServiceSectionHeading: View {
    let kind: ServiceOverview.Kind
    let count: Int

    var body: some View {
        HStack {
            Text(kind.title)
            Spacer()
            Text(count, format: .number)
                .monospacedDigit()
                .font(.caption.weight(.medium))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 7)
                .padding(.vertical, 2)
                .background(.primary.opacity(0.06), in: .capsule)
        }
        .font(.subheadline.weight(.semibold))
        .foregroundStyle(.primary)
    }
}

private struct IncidentRow: View {
    let row: ServiceOverview.Row
    let showScope: Bool
    @Binding var isExpanded: Bool

    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            IncidentDetails(row: row)
                .padding(.leading, 24)
                .padding(.bottom, 10)
        } label: {
            ServiceRowLabel(row: row, showScope: showScope)
        }
        .disclosureGroupStyle(ServiceDisclosureStyle())
    }
}

private struct ServiceDisclosureStyle: DisclosureGroupStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Button {
                configuration.isExpanded.toggle()
            } label: {
                HStack(spacing: 8) {
                    configuration.label
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Image(systemName: configuration.isExpanded ? "chevron.down" : "chevron.right")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .accessibilityHidden(true)
                }
                .padding(.vertical, 10)
                .contentShape(.rect)
            }
            .buttonStyle(ServiceRowButtonStyle())
            .accessibilityValue(Text(configuration.isExpanded ? "Expanded" : "Collapsed", bundle: .statusUI))

            if configuration.isExpanded {
                configuration.content
            }
        }
    }
}

private struct ServiceRowButtonStyle: ButtonStyle {
    @State private var isHovered = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(.primary.opacity(configuration.isPressed ? 0.1 : isHovered ? 0.05 : 0), in: .rect(cornerRadius: 8))
            .onHover { isHovered = $0 }
    }
}

private struct ServiceRowLabel: View {
    let row: ServiceOverview.Row
    let showScope: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: row.kind.symbol)
                .foregroundStyle(row.kind.color)
                .frame(width: 16)
                .padding(.top, 2)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 3) {
                Text(row.item.title)
                    .font(.body)
                    .foregroundStyle(.primary)
                    .fixedSize(horizontal: false, vertical: true)
                HStack(spacing: 4) {
                    if showScope {
                        Text(row.scope == .developer ? "Developer" : "Customer", bundle: .statusUI)
                        Text(verbatim: "·")
                    }
                    Text(row.kind.status)
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)
        }
        .accessibilityElement(children: .combine)
    }
}

private struct IncidentDetails: View {
    let row: ServiceOverview.Row

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if row.kind == .scheduled, let start = row.item.formattedScheduledStartTime {
                if let end = row.item.formattedScheduledEndTime {
                    Text("\(start) – \(end)", bundle: .statusUI)
                        .font(.callout.weight(.medium))
                } else {
                    Text(start).font(.callout.weight(.medium))
                }
            } else if row.kind == .resolved, let end = row.item.formattedResolutionTime {
                Text("Ended \(end)", bundle: .statusUI)
                    .font(.callout.weight(.medium))
            }
            if let message = row.item.subtitle {
                Text(message)
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .textSelection(.enabled)
            }
            if row.kind == .active {
                ServiceNotificationButton(serviceID: row.item.id, scope: row.scope)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct ServiceNotificationButton: View {
    @Environment(NotificationManager.self) private var notificationManager
    let serviceID: String
    let scope: ServiceScope

    var body: some View {
        let enabled = notificationManager.hasNotificationsEnabled(for: serviceID, in: scope)
        Button {
            notificationManager.toggleNotificationsEnabled(for: serviceID, in: scope)
        } label: {
            Label {
                Text(enabled ? "Notification on" : "Notify when restored", bundle: .statusUI)
            } icon: {
                Image(systemName: enabled ? "bell.badge.fill" : "bell")
            }
        }
        .buttonStyle(.glass)
        .controlSize(.small)
        .accessibilityValue(Text(enabled ? "On" : "Off", bundle: .statusUI))
        .help(Text(enabled ? "Stop notifying when this service is restored" : "Notify when this service is restored", bundle: .statusUI))
    }
}

private struct DashboardFooter: View {
    let lastUpdated: Date?

    var body: some View {
        HStack {
            if let lastUpdated {
                Text("Checked \(lastUpdated, format: .dateTime.hour().minute())", bundle: .statusUI)
            }
            Spacer(minLength: 4)
            Link(destination: URL(string: "https://www.apple.com/support/systemstatus/")!) {
                Text("Apple System Status", bundle: .statusUI)
            }
        }
        .font(.caption)
        .foregroundStyle(.secondary)
    }
}

#if DEBUG
import StatusCore

#Preview("Root") {
    DashboardView(viewModel: try! .preview(with: [
        .customer: .customerNoIssues(), .developer: .developerNoIssues()
    ]))
        .frame(width: RootView.minWidth)
        .windowChrome()
        .environment(NotificationManager())
}

#Preview("Expanded incident") {
    IncidentRow(
        row: ServiceOverview.Row(item: DetailGroup.activeIssuesPreview.items[0], scope: .developer, kind: .active),
        showScope: true,
        isExpanded: .constant(true)
    )
    .environment(NotificationManager())
    .padding(20)
    .frame(width: 368)
    .background(Color(nsColor: .windowBackgroundColor))
}

#Preview("Issues and maintenance") {
    DashboardView(viewModel: try! .preview(with: [
        .customer: .customerThreeOngoingIssues(), .developer: .developerOneScheduledIssue()
    ]))
        .frame(width: RootView.minWidth)
        .windowChrome()
        .environment(NotificationManager())
}

#Preview("Unable to load") {
    DashboardView(viewModel: RootViewModel(dashboard: DashboardViewModel(with: .failure("Offline"))))
        .frame(width: RootView.minWidth, height: 560)
        .windowChrome()
}
#endif
