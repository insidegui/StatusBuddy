import SwiftUI

public extension ProcessInfo {

    /// In debug builds, `true` if the current process is running in a SwiftUI preview.
    /// Always `false` in release builds.
    @objc static let isSwiftUIPreview: Bool = {
        #if DEBUG
        return processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
        #else
        return false
        #endif
    }()

    /// In debug builds, `true` if the current process is running in a SwiftUI preview.
    /// Always `false` in release builds.
    var isSwiftUIPreview: Bool { Self.isSwiftUIPreview }

}
