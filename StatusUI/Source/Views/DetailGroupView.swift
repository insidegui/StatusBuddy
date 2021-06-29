//
//  DetailGroupView.swift
//  StatusBuddyNewUIPrototype
//
//  Created by Guilherme Rambo on 28/06/21.
//

import SwiftUI

struct DetailGroupItemView: View {
    let item: DetailGroupItem
    
    init(_ item: DetailGroupItem) { self.item = item }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(item.title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.primaryText)
            if let subtitle = item.subtitle {
                Text(subtitle)
                    .font(.system(size: 11))
                    .foregroundColor(.secondaryText)
            }
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }
}

struct DetailGroupView: View {
    let group: DetailGroup
    let configureNotifications: (() -> Void)?
    
    init(_ group: DetailGroup, configureNotifications: (() -> Void)? = nil) {
        self.group = group
        self.configureNotifications = configureNotifications
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 2) {
                Image(systemName: group.iconName)
                Text(group.title)
                Spacer()
                
                if group.supportsNotifications {
                    Button {
                        assert(configureNotifications != nil)
                        configureNotifications?()
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .foregroundColor(Color.primaryText)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .accessibility(label: Text("Configure Notifications"))
                }
            }
            .foregroundColor(group.accentColor)
            .font(.system(size: 11, weight: .medium))
            
            VStack(alignment: .leading, spacing: 10) {
                ForEach(group.items) { item in
                    VStack {
                        DetailGroupItemView(item)
                        if item.id != group.items.last?.id {
                            Divider()
                                .foregroundColor(.groupSeparator)
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
            iconName: "exclamationmark.triangle.fill",
            title: "RECENT ISSUES",
            accentColor: .warning,
            supportsNotifications: false,
            items: [
                DetailGroupItem(
                    id: "Developer ID Notary Service",
                    title: "Developer ID Notary Service",
                    subtitle: "Developer ID Notary Service was temporarily unavailable during system maintenance."
                ),
                DetailGroupItem(
                    id: "App Store Connect",
                    title: "App Store Connect",
                    subtitle: "Users may have experienced issues with the service."
                )
            ]
        )
    }()
    
    static let activeIssuesPreview: DetailGroup = {
        DetailGroup(
            id: "ACTIVE",
            iconName: "x.circle.fill",
            title: "ACTIVE ISSUES",
            accentColor: .error,
            supportsNotifications: true,
            items: [
                DetailGroupItem(
                    id: "Developer ID Notary Service",
                    title: "Developer ID Notary Service",
                    subtitle: "Developer ID Notary Service is temporarily unavailable during system maintenance."
                ),
                DetailGroupItem(
                    id: "App Store Connect",
                    title: "App Store Connect",
                    subtitle: "Users may be experiencing issues with the service."
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
