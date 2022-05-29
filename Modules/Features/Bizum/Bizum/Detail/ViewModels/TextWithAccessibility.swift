import UI

final class TextWithAccessibility {
    private(set) var text: String
    private(set) var accessibility: String?
    private(set) var attribute: NSAttributedString?
    private(set) var style: LocalizedStylableTextConfiguration?

    init(text: String, accessibility: String? = nil, attribute: NSAttributedString? = nil, style: LocalizedStylableTextConfiguration? = nil) {
        self.text = text
        self.accessibility = accessibility
        self.attribute = attribute
        self.style = style
    }

    func setAttribute(_ attribute: NSAttributedString) {
        self.attribute = attribute
    }

    func setStyle(_ style: LocalizedStylableTextConfiguration) {
        self.style = style
    }

    func setAccessibility(_ value: String) {
        self.accessibility = value
    }
}

extension UILabel {
    
    func configureWithTextAndAccessibility(_ textWithAccessibility: TextWithAccessibility) {
        self.configureText(withKey: textWithAccessibility.text)
        self.accessibilityIdentifier = textWithAccessibility.accessibility
    }
}
