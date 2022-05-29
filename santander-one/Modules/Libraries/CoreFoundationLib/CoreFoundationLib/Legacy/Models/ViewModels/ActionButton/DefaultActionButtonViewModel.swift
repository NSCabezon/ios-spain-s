public protocol DefaultActionButtonViewModelProtocol {
    var title: String { get }
    var imageKey: String { get }
    var renderingMode: UIImage.RenderingMode { get }
    var titleAccessibilityIdentifier: String { get }
    var imageAccessibilityIdentifier: String { get }
    var accessibilityButtonValue: String { get }
}

public struct DefaultActionButtonViewModel: Equatable, DefaultActionButtonViewModelProtocol {
    public let title: String
    public let imageKey: String
    public let renderingMode: UIImage.RenderingMode
    public let titleAccessibilityIdentifier: String
    public let imageAccessibilityIdentifier: String
    public let accessibilityButtonValue: String
    
    public init(title: String,
                imageKey: String,
                renderingMode: UIImage.RenderingMode = .alwaysTemplate,
                titleAccessibilityIdentifier: String,
                imageAccessibilityIdentifier: String,
                accessibilityButtonValue: String? = nil) {
        self.title = title
        self.imageKey = imageKey
        self.renderingMode = renderingMode
        self.titleAccessibilityIdentifier = titleAccessibilityIdentifier.isEmpty ? title : titleAccessibilityIdentifier
        self.imageAccessibilityIdentifier = imageAccessibilityIdentifier
        self.accessibilityButtonValue = accessibilityButtonValue ?? title
    }
}
