import Foundation

public struct SecurityViewModel {
    public let title: String
    public let subtitle: String
    public let icon: String
    
    public init(title: String, subtitle: String, icon: String) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
    }
}
