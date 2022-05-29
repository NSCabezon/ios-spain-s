public struct HighlightedInfo {
    public enum HighlightedInfoStyle {
        case skyGray
        case darkTurquoise
    }
    public let text: String
    public let isDragDisabled: Bool
    public let style: HighlightedInfoStyle?
    
    public init(text: String, isDragDisabled: Bool, style: HighlightedInfoStyle? = nil) {
        self.text = text
        self.isDragDisabled = isDragDisabled
        self.style = style
    }
}
