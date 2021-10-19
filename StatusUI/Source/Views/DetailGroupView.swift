//
//  DetailGroupView.swift
//  StatusBuddyNewUIPrototype
//
//  Created by Guilherme Rambo on 28/06/21.
//

import SwiftUI

struct DetailGroupItemView: View {
    @EnvironmentObject var notificationManager: NotificationManager
    
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
                    .foregroundColor(.primaryText)
                
                Spacer()
                
                if group.supportsNotifications { notificationView }
            }
            
            Group {
                if let resolutionTime = item.formattedResolutionTime {
                    Text("Ended " + resolutionTime)
                        .font(.system(size: 12, weight: .medium))
                }

                if let subtitle = item.subtitle {
                    Text(subtitle)
                        .font(.system(size: 11))
                }
            }
            .foregroundColor(.secondaryText)
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }
    
    private var notificationView: some View {
        Button {
            notificationManager.toggleNotificationsEnabled(for: item.id, in: group.scope)
        } label: {
            Image(systemName: "rectangle.fill.badge.checkmark")
                .foregroundColor(notificationManager.hasNotificationsEnabled(for: item.id, in: group.scope) ? Color.accent : Color.primaryText)
        }
        .buttonStyle(PlainButtonStyle())
        .accessibility(label: Text("Configure Notifications"))
    }
}

struct DetailGroupView: View {
    let group: DetailGroup
    
    init(_ group: DetailGroup) {
        self.group = group
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 2) {
                Image(systemName: group.iconName)
                Text(group.title)
                Spacer()
            }
            .foregroundColor(group.accentColor)
            .font(.system(size: 11, weight: .medium))
            
            VStack(alignment: .leading, spacing: 10) {
                ForEach(group.items) { item in
                    VStack {
                        DetailGroupItemView(for: item, in: group)
                        if item.id != group.items.last?.id {
                            if #available(macOS 12.0, *) {
                                Rectangle()
                                    .frame(height: 0.5)
                                    .foregroundStyle(.tertiary)
                                    .opacity(0.3)
                                    .accessibility(hidden: true)
                            } else {
                                Divider()
                                    .foregroundColor(.groupSeparator)
                            }
                        }
                    }
                }
            }
        }
        .statusItemBackground(padding: 10)
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

struct DetailGroupView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            DetailGroupView(.recentIssuesPreview)
                .preferredColorScheme(.light)
            DetailGroupView(.recentIssuesPreview)
                .preferredColorScheme(.dark)
            
            DetailGroupView(.activeIssuesPreview)
                .preferredColorScheme(.light)
            DetailGroupView(.activeIssuesPreview)
                .preferredColorScheme(.dark)
        }
    }
}
#endif
