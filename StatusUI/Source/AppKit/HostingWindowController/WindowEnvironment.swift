//
//  WindowEnvironment.swift
//  StatusBuddy
//
//  Created by Guilherme Rambo on 21/12/21.
//  Copyright © 2021 Guilherme Rambo. All rights reserved.
//

import SwiftUI

// MARK: - Public API

public extension EnvironmentValues {
    
    /// Closes the window that's hosting this view.
    /// Only available when the view hierarchy is being presented with `HostingWindowController`.
    var closeWindow: () -> Void {
        get { self[CloseWindowEnvironmentKey.self] }
        set { self[CloseWindowEnvironmentKey.self] = newValue }
    }
    
}

public extension View {
    
    /// Sets the title for the window that contains this SwiftUI view.
    /// Only available when the view hierarchy is being presented with `HostingWindowController`.
    func windowTitle(_ title: String) -> some View {
        environment(\.windowTitle, title)
    }
    
}

// MARK: - Hosting Window Environment Keys

private struct CloseWindowEnvironmentKey: EnvironmentKey {
    static let defaultValue: () -> Void = { }
}

private struct WindowTitleEnvironmentKey: EnvironmentKey {
    static let defaultValue: String = ""
}

private struct HostingWindowKey: EnvironmentKey {
    static let defaultValue: () -> NSWindow? = { nil }
}

extension EnvironmentValues {
    
    /// Set and used internally by `HostingWindowController`.
    var cocoaWindow: NSWindow? {
        get { self[HostingWindowKey.self]() }
        set { self[HostingWindowKey.self] = { [weak newValue] in newValue } }
    }
    
    var windowTitle: String {
        get { self[WindowTitleEnvironmentKey.self] }
        set {
            self[WindowTitleEnvironmentKey.self] = newValue
            cocoaWindow?.title = newValue
        }
    }
    
}
