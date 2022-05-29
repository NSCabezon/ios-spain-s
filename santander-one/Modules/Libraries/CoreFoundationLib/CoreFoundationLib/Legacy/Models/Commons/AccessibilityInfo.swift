public struct AccessibilityInfo {
    public let accessibilityIdentifier: String?
    public let accessibilityLabel: String?
    public let accessibilityValue: String?
    public let accessibilityHint: String?
    
    public init(accessibilityIdentifier: String? = nil, accessibilityLabel: String? = nil, accessibilityValue: String? = nil, accessibilityHint: String? = nil) {
        self.accessibilityIdentifier = accessibilityIdentifier
        self.accessibilityLabel = accessibilityLabel
        self.accessibilityValue = accessibilityValue
        self.accessibilityHint = accessibilityHint
    }
}
