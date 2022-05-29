public struct CenteredImageActionButtonViewModel: Equatable {
    public let imageKey: String
    public let renderingMode: UIImage.RenderingMode
    public let imageAccessibilityIdentifier: String
    
    public init(
        imageKey: String,
        renderingMode: UIImage.RenderingMode = .alwaysTemplate,
        imageAccessibilityIdentifier: String
    ) {
        self.imageKey = imageKey
        self.renderingMode = renderingMode
        self.imageAccessibilityIdentifier = imageAccessibilityIdentifier
    }
}
