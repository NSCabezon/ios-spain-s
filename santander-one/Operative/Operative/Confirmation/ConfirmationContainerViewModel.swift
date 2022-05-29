import CoreFoundationLib

public typealias ConfirmationContainerAction = (title: String, action: () -> Void)

public final class ConfirmationContainerViewModel {
    public enum Position {
        case first
        case unknown
        case last
    }
    
    public let title: LocalizedStylableText
    public let action: ConfirmationContainerAction?
    public let position: Position
    public var views: [UIView]
    
    public init(title: LocalizedStylableText,
                position: Position = .unknown,
                action: ConfirmationContainerAction? = nil,
                views: [UIView] = []) {
        self.title = title
        self.action = action
        self.position = position
        self.views = views
    }
    
    public func addViewsAtModel(_ views: [UIView]) {
        self.views = views
    }
    
    public func addViewAtModel(_ views: UIView) {
        self.views.append(views)
    }
}
