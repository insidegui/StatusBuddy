//
//  DetailGroupView.swift
//  StatusBuddyNewUIPrototype
//
//  Created by Guilherme Rambo on 28/06/21.
//

import SwiftUI

struct DetailGroupItemView: View {
    @Environment(NotificationManager.self) private var notificationManager
    
    let item: DetailGroupItem
    let group: DetailGroup
    
    init(for item: DetailGroupItem, in group: DetailGroup) {
        self.item = item
        self.group = group
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(item.title)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.primary)
                
                Spacer()
                
                if group.supportsNotifications { notificationView }
            }
            
            Group {
                if let resolutionTime = item.formattedResolutionTime {
                    if let startTime = item.formattedScheduledStartTime, let endTime = item.formattedScheduledEndTime {
                        Text("\(startTime) — \(endTime)")
                            .font(.system(size: 12, weight: .medium))
                    } else {
                        Text("Ended " + resolutionTime)
                            .font(.system(size: 12, weight: .medium))
                    }
                }

                if let subtitle = item.subtitle {
                    Text(subtitle)
                        .font(.system(size: 11))
                }
            }
            .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }
    
    private var notificationView: some View {
        Button {
            notificationManager.toggleNotificationsEnabled(for: item.id, in: group.scope)
        } label: {
            Image(systemName: "rectangle.fill.badge.checkmark")
                .foregroundStyle(notificationManager.hasNotificationsEnabled(for: item.id, in: group.scope) ? Color.accent : Color.primaryText)
        }
        .buttonStyle(.bordered)
        .buttonBorderShape(.circle)
        .accessibilityLabel("Configure Notifications")
        .accessibilityValue(notificationManager.hasNotificationsEnabled(for: item.id, in: group.scope) ? "On" : "Off")
        .help("Notify when this service is restored")
    }
}

struct DetailGroupView: View {
    let group: DetailGroup
    
    init(_ group: DetailGroup) {
        self.group = group
    }

    @Namespace private var namespace

    var body: some View {
        Section {
            VStack(alignment: .leading, spacing: 10) {
                ForEach(group.items) { item in
                    VStack {
                        DetailGroupItemView(for: item, in: group)
                        if item.id != group.items.last?.id {
                            Divider()
                                .accessibilityHidden(true)
                        }
                    }
                }
            }
            .padding(12)
        } header: {
            HStack(spacing: 2) {
                Text(group.title)
                Spacer()
                Image(systemName: group.iconName)
            }
            .font(.headline.weight(.medium))
//            .foregroundStyle(group.accentColor)
            .padding(12)
            .glassEffect(.clear.tint(group.accentColor), in: .containerRelative)
            .glassEffectTransition(.materialize)
        }
    }
}

#if DEBUG
extension DetailGroup {
    static let recentIssuesPreview: DetailGroup = {
        DetailGroup(
            id: "RECENTS",
            scope: .developer,
            iconName: "exclamationmark.triangle.fill",
            title: "RECENT ISSUES",
            accentColor: .warning,
            supportsNotifications: false,
            items: [
                DetailGroupItem(
                    id: "Developer ID Notary Service",
                    title: "Developer ID Notary Service",
                    subtitle: "Developer ID Notary Service was temporarily unavailable during system maintenance.",
                    formattedResolutionTime: "2 hours ago"
                ),
                DetailGroupItem(
                    id: "App Store Connect",
                    title: "App Store Connect",
                    subtitle: "Users may have experienced issues with the service.",
                    formattedResolutionTime: "5 hours ago"
                )
            ]
        )
    }()
    
    static let activeIssuesPreview: DetailGroup = {
        DetailGroup(
            id: "ACTIVE",
            scope: .developer,
            iconName: "x.circle.fill",
            title: "ACTIVE ISSUES",
            accentColor: .error,
            supportsNotifications: true,
            items: [
                DetailGroupItem(
                    id: "Developer ID Notary Service",
                    title: "Developer ID Notary Service",
                    subtitle: "Developer ID Notary Service is temporarily unavailable during system maintenance.",
                    formattedResolutionTime: nil
                ),
                DetailGroupItem(
                    id: "App Store Connect",
                    title: "App Store Connect",
                    subtitle: "Users may be experiencing issues with the service.",
                    formattedResolutionTime: nil
                )
            ]
        )
    }()
}

#Preview("Recent Issues") {
    DetailView(viewModel: .preview, scope: .customer, groups: [.recentIssuesPreview])
        .environment(NotificationManager())
        .windowChrome()
        .contentMargins(12, for: .scrollContent)
}

#Preview("Active Issues") {
    DetailView(viewModel: .preview, scope: .customer, groups: [.activeIssuesPreview])
        .environment(NotificationManager())
        .windowChrome()
        .contentMargins(12, for: .scrollContent)
}
#endif
