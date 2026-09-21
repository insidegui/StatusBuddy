import SwiftUI

public extension View {
    /// Modifies a view using a view builder.
    /// - Parameter modifier: A view builder that can be used to modify the view.
    /// - Returns: The modified view.
    ///
    /// This is useful when you need to apply a view modifier conditionally, for example if it's only available in a certain OS/version.
    ///
    /// Example:
    ///
    /// ```swift
    /// Text("Hello, World").modifier {
    ///     if #available(iOS 26, *) {
    ///         $0.glassEffect(.regular)
    ///     } else {
    ///         $0
    ///     }
    /// }
    /// ```
    ///
    /// Original implementation by @kylebshr - https://gist.github.com/kylebshr/fb71107a34d743cd9eb53bf1d028cc01
    func modifier(@ViewBuilder _ modifier: (Self) -> some View) -> some View {
        modifier(self)
    }
}
