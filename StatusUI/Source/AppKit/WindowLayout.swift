import SwiftUI
import Observation

struct WindowLayout {
    /// Keeps the window clear of the screen edges, menu bar, and Dock.
    var visibleFramePadding: CGFloat = 12
    /// The default visible screen height fraction to use when a screen is not available.
    var defaultMaximumContentHeightFraction: Double = 0.84

    static let `default` = WindowLayout()
}

extension WindowLayout {
    func availableWindowFrame(for screen: NSScreen) -> CGRect {
        let visibleFrame = screen.visibleFrame
        let horizontalPadding = Swift.min(visibleFramePadding, Swift.max(0, (visibleFrame.width - 1) / 2))
        let verticalPadding = Swift.min(visibleFramePadding, Swift.max(0, (visibleFrame.height - 1) / 2))

        return visibleFrame.insetBy(dx: horizontalPadding, dy: verticalPadding)
    }

    func maximumContentHeight(for window: NSWindow) -> Double {
        guard let screen = window.screen ?? NSScreen.main ?? NSScreen.screens.first else {
            return .screenVisibleHeight(defaultMaximumContentHeightFraction)
        }

        let availableWindowFrame = availableWindowFrame(for: screen)

        return max(1, window.contentRect(forFrameRect: availableWindowFrame).height)
    }
}

extension Double {
    /// Helper to obtain a value that's a fraction of the main screen's visible height with sensible fallbacks.
    static func screenVisibleHeight(_ multiplier: Double, min minHeight: Double = 540, fallback: Double = 720) -> Double {
        if let screenHeight = NSScreen.main?.visibleFrame.height {
            Swift.max(screenHeight * multiplier, minHeight)
        } else {
            fallback
        }
    }
}

@MainActor
@Observable
final class WindowGeometry {
    let layout: WindowLayout
    private(set) var maximumContentHeight: Double

    init(layout: WindowLayout) {
        self.layout = layout
        self.maximumContentHeight = .screenVisibleHeight(layout.defaultMaximumContentHeightFraction)
    }

    func update(window: NSWindow) {
        self.maximumContentHeight = layout.maximumContentHeight(for: window)
    }
}
