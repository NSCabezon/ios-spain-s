import Foundation

public protocol CustomUniversalLinkManager {
    func registerUniversalLinkWithURL(_ url: URL) -> Bool
}
