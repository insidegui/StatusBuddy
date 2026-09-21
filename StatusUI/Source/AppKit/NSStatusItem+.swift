import AppKit

extension NSStatusItem {
    func sb_startExpandedInterfaceSession() -> Bool {
        SPI.startExpandedInterfaceSession(self)
    }

    /// Ugly hack until public API is available (FB23688090)
    /// See https://github.com/feedback-assistant/reports/issues/821
    private enum SPI {
        static let expandedInterfaceSessionSuffix = "ExpandedInterfaceSession"
        static let requestStringSPIPrefix = "_request"
        static let requestStringAPIPrefix = "request"

        static let isRequestSPIAvailable = NSStatusItem.instancesRespond(to: NSSelectorFromString(requestStringSPIPrefix + expandedInterfaceSessionSuffix))
        static let isRequestAPIAvailable = NSStatusItem.instancesRespond(to: NSSelectorFromString(requestStringAPIPrefix + expandedInterfaceSessionSuffix))

        static func startExpandedInterfaceSession(_ statusItem: NSStatusItem) -> Bool {
            guard #available(macOS 27, *) else { return false }

            if isRequestAPIAvailable {
                NSApp.sendAction(NSSelectorFromString(requestStringAPIPrefix + expandedInterfaceSessionSuffix), to: statusItem, from: nil)

                return true
            } else if isRequestSPIAvailable {
                NSApp.sendAction(NSSelectorFromString(requestStringSPIPrefix + expandedInterfaceSessionSuffix), to: statusItem, from: nil)

                return true
            } else {
                return false
            }
        }
    }
}
