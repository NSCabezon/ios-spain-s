public struct DefaultActionButtonWithBackgroundViewModel: DefaultActionButtonViewModelProtocol, Equatable {
    public let title: String
    public let imageKey: String
    public let renderingMode: UIImage.RenderingMode
    public let titleAccessibilityIdentifier: String
    public let imageAccessibilityIdentifier: String
    public let backgroundKey: String?
    public let accessibilityButtonValue: String
    
    public init(title: String,
                imageKey: String,
                renderingMode: UIImage.RenderingMode = .alwaysTemplate,
                titleAccessibilityIdentifier: String,
                imageAccessibilityIdentifier: String,
                backgroundKey: String?,
                accessibilityButtonValue: String? = nil) {
        self.title = title
        self.imageKey = imageKey
        self.renderingMode = renderingMode
        self.titleAccessibilityIdentifier = titleAccessibilityIdentifier
        self.imageAccessibilityIdentifier = imageAccessibilityIdentifier
        self.backgroundKey = backgroundKey
        self.accessibilityButtonValue = accessibilityButtonValue ?? title
    }
}
