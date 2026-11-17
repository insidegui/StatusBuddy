import AppKit

extension NSImage {
    /// An NSTextField badge triggers a snapshot invalidation loop in AppKit on macOS 27,
    /// so StatusBuddy now uses a dynamic `NSImage` to render the badge.
    func addingIssueBadge(layoutDirection: NSUserInterfaceLayoutDirection) -> NSImage {
        let badgeColor = NSColor(named: "IssueBadgeColor") ?? .systemRed
        let palette = SymbolConfiguration(paletteColors: [.white, badgeColor])
        let symbol = NSImage(systemSymbolName: "exclamationmark.circle.fill", accessibilityDescription: nil)
        guard let badge = symbol?.withSymbolConfiguration(palette) else { return self }

        let result = NSImage(size: size, flipped: false) { rect in
            guard let context = NSGraphicsContext.current?.cgContext else { return false }

            let diameter: CGFloat = 10
            let x = layoutDirection == .rightToLeft ? rect.minX : rect.maxX - diameter
            let badgeRect = NSRect(x: x, y: rect.maxY - diameter, width: diameter, height: diameter)

            context.beginTransparencyLayer(auxiliaryInfo: nil)
            self.drawStatusIcon(in: rect, clearingBadgeRect: badgeRect, context: context)
            badge.draw(in: badgeRect)
            context.endTransparencyLayer()
            return true
        }
        // Resolve the icon tint using the current drawing appearance.
        result.cacheMode = .never
        return result
    }

    private func drawStatusIcon(in rect: NSRect, clearingBadgeRect badgeRect: NSRect, context: CGContext) {
        draw(in: rect)

        context.saveGState()
        context.setBlendMode(.sourceIn)
        context.setFillColor(NSColor.labelColor.cgColor)
        context.fill(rect)

        context.setBlendMode(.clear)
        context.fillEllipse(in: badgeRect.insetBy(dx: -1, dy: -1))
        context.restoreGState()
    }
}
