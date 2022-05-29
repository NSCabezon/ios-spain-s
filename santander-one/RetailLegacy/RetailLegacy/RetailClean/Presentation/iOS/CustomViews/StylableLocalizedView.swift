import UIKit

protocol StylableLocalizedButton: LocalizedStylableTextProcessor {
    func set(localizedStylableText: LocalizedStylableText, state: UIControl.State, completion: (() -> Void)?)
}

protocol StylableLocalizedField: LocalizedStylableTextProcessor {
    func set(localizedStylableText: LocalizedStylableText)
    func setOnPlaceholder(localizedStylableText: LocalizedStylableText)
    func setOnPlaceholder(localizedStylableText: LocalizedStylableText, attributes: [NSAttributedString.Key: Any]?)
}

protocol StylableLocalizedView: LocalizedStylableTextProcessor {
    func set(localizedStylableText: LocalizedStylableText)
}

protocol LocalizedStylableTextProcessor {}

extension LocalizedStylableTextProcessor {
    func processAttributedTextFrom(localizedStylableText: LocalizedStylableText, withFont font: UIFont, andAlignment alignment: NSTextAlignment) -> NSAttributedString? {
        return self.attributedTextFrom(localizedStylableText: localizedStylableText, withFont: font, andAlignment: alignment)
    }
    
    func processAttributedTextInMainThreadFrom(localizedStylableText: LocalizedStylableText, withFont font: UIFont, andAlignment alignment: NSTextAlignment) -> NSAttributedString? {
            return attributedTextFrom(localizedStylableText: localizedStylableText, withFont: font, andAlignment: alignment)
    }
    
    private func attributedTextFrom(localizedStylableText: LocalizedStylableText, withFont font: UIFont, andAlignment alignment: NSTextAlignment) -> NSAttributedString? {
        guard let styles = localizedStylableText.styles else {
            return nil
        }
        let style = NSMutableParagraphStyle()
        style.alignment = alignment
        let attributed = NSMutableAttributedString(string: localizedStylableText.text, attributes: [NSAttributedString.Key.paragraphStyle: style])
        styles.forEach { style in
            switch style.attribute {
            case .font(let emphasis, let factor):
                if let font = font.font(with: emphasis, factor: CGFloat(factor)) {
                    attributed.addAttributes([.font: font], range: style.range)
                }
            case .color(let hexString):
                attributed.addAttributes([.foregroundColor: UIColor.fromHex(hexString.replace("#", ""))], range: style.range)
            case .underline:
                attributed.addAttributes([.underlineStyle: NSUnderlineStyle.single.rawValue], range: style.range)
            case .link:
                break
                
            }
        }
        return attributed
    }
}

extension UILabel: StylableLocalizedView {
    func set(localizedStylableText: LocalizedStylableText) {
        if localizedStylableText.styles != nil {
            let fontField = font ?? UIFont.font(name: font.fontName, size: UIFont.systemFontSize)
            let text = processAttributedTextFrom(localizedStylableText: localizedStylableText, withFont: fontField, andAlignment: textAlignment)
            font = UIFont.font(name: fontField.fontName, size: fontField.pointSize)
            attributedText = text
        } else {
            text = localizedStylableText.text
        }
    }
}

extension UITextView: StylableLocalizedView {
    func set(localizedStylableText: LocalizedStylableText) {
        if localizedStylableText.styles != nil {
            let fontField = font ?? UIFont.font(name: font?.fontName ?? "SantanderText-Regular", size: UIFont.systemFontSize)
            let text = processAttributedTextFrom(localizedStylableText: localizedStylableText, withFont: fontField, andAlignment: textAlignment)
            font = UIFont.font(name: fontField.fontName, size: fontField.pointSize)
            attributedText = text
        } else {
            text = localizedStylableText.text
        }
    }
}

extension UITextField: StylableLocalizedField {

    func set(localizedStylableText: LocalizedStylableText) {
        if localizedStylableText.styles != nil {
            let fontField = font ?? UIFont.font(name: font?.fontName ?? "SantanderText-Regular", size: UIFont.systemFontSize)
            let text = processAttributedTextFrom(localizedStylableText: localizedStylableText, withFont: fontField, andAlignment: textAlignment)
            font = UIFont.font(name: fontField.fontName, size: fontField.pointSize)
            attributedText = text
        } else {
            text = localizedStylableText.text
        }
    }

    func setOnPlaceholder(localizedStylableText: LocalizedStylableText) {
        if localizedStylableText.styles != nil {
            let fontField = font ?? .latoItalic(size: 16)
            let text = processAttributedTextFrom(localizedStylableText: localizedStylableText, withFont: fontField, andAlignment: textAlignment)
            font = UIFont.font(name: fontField.fontName, size: fontField.pointSize)
            attributedPlaceholder = text
        } else {
            placeholder = localizedStylableText.text
        }
    }

    func setOnPlaceholder(localizedStylableText: LocalizedStylableText, attributes: [NSAttributedString.Key: Any]?) {
        if attributes != nil {
            let attributedString = NSAttributedString(string: localizedStylableText.text, attributes: attributes)
            self.attributedPlaceholder = attributedString
        } else {
            setOnPlaceholder(localizedStylableText: localizedStylableText)
        }
    }

}

extension UIButton: StylableLocalizedButton {
    
    func set(localizedStylableText: LocalizedStylableText, state: UIControl.State, completion: (() -> Void)? = nil) {
        if localizedStylableText.styles != nil, let label = titleLabel {
            let text = processAttributedTextFrom(localizedStylableText: localizedStylableText, withFont: label.font, andAlignment: label.textAlignment)
            label.font = UIFont.font(name: label.font.fontName, size: label.font.pointSize)
            self.setAttributedTitle(text, for: state)
        } else {
            setTitle(localizedStylableText.text, for: state)
            if let completion = completion {
                completion()
            }
        }
    }
    
    func setAccessibilityIdentifiers(buttonAccessibilityIdentifier: String, titleLabelAccessibilityIdentifier: String) {
        self.accessibilityIdentifier = buttonAccessibilityIdentifier
        self.titleLabel?.accessibilityIdentifier = titleLabelAccessibilityIdentifier
    }
}

extension UIFont {
    func font(with emphasis: FontEmphasis, factor: CGFloat = 1.0) -> UIFont? {
        guard let fontName = fontName.split("-").first else {
            return nil
        }
        var fullFontName = fontName
        if !emphasis.rawValue.isEmpty {
            fullFontName += "-" + emphasis.rawValue
        }
        
        return UIFont(name: fullFontName, size: pointSize * factor)
    }
}
