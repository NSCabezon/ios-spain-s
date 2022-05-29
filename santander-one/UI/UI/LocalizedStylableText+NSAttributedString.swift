import CoreFoundationLib
import UIKit

public protocol LocalizedStylableComponent: AnyObject {
    var textFont: UIFont? { get set }
    var componentTextColor: UIColor? { get set }
    var textAlignment: NSTextAlignment { get set }
    var lineBreakMode: NSLineBreakMode { get set }
    var linkAttributes: [NSAttributedString.Key: Any] { get set }
}

extension UILabel: LocalizedStylableComponent {
    public var componentTextColor: UIColor? {
        get {
            return self.textColor
        }
        set {
            self.textColor = newValue
        }
    }
    public var linkAttributes: [NSAttributedString.Key: Any] {
        get {
            return [:]
        }
        set {
            // Nothing to do in UILabel
        }
    }
    public var textFont: UIFont? {
        get {
            return self.font
        }
        set {
            self.font = newValue
        }
    }
}

extension UITextView: LocalizedStylableComponent {
    public var componentTextColor: UIColor? {
        get {
            return self.textColor
        }
        set {
            self.textColor = newValue
        }
    }
    public var linkAttributes: [NSAttributedString.Key: Any] {
        get {
            return self.linkTextAttributes
        }
        set {
            self.linkTextAttributes = newValue
        }
    }
    public var textFont: UIFont? {
        get {
            return self.font
        }
        set {
            self.font = newValue
        }
    }
    public var lineBreakMode: NSLineBreakMode {
        get {
            self.textContainer.lineBreakMode
        }
        set {
            self.textContainer.lineBreakMode = newValue
        }
    }
}

/// Configuration for getting attributed strings from LocalizedStylableText.
public struct LocalizedStylableTextConfiguration {
    let font: UIFont?
    let textStyles: [NormalizedStyling]?
    let alignment: NSTextAlignment?
    let lineHeightMultiple: CGFloat?
    let lineBreakMode: NSLineBreakMode?
    
    public init(font: UIFont? = nil,
                textStyles: [NormalizedStyling]? = nil,
                alignment: NSTextAlignment? = nil,
                lineHeightMultiple: CGFloat? = nil,
                lineBreakMode: NSLineBreakMode? = nil) {
        self.font = font
        self.textStyles = textStyles
        self.alignment = alignment
        self.lineHeightMultiple = lineHeightMultiple
        self.lineBreakMode = lineBreakMode
    }
}

extension LocalizedStylableText {
    /**
    Converts LocalizedStylableText to an attributed string.

    - Parameter component: The text component where the text belongs.
    - Parameter configuration: The configuration for adding style to the text. If any property is nil, the configuration will fallback to the one present in the label.

    - Returns: A new attributed string with the configuration passed as parameter.
    */
    public func asAttributedString(for component: LocalizedStylableComponent,
                                   _ configuration: LocalizedStylableTextConfiguration? = nil) -> NSAttributedString {
        let configuration = configuration ?? LocalizedStylableTextConfiguration()
        let builder = AttributedStringBuilder(string: self.text)
        let styles = configuration.textStyles ?? self.styles ?? []
        let font: UIFont = configuration.font ?? component.textFont ?? UIFont.santander(size: 12)
        if let color = component.componentTextColor {
            _ = builder.addColor(color)
        }
        _ = builder.addFont(font)
        for style in styles {
            switch style.attribute {
            case .font(let emphasis, let factor):
                if let font = font.font(with: emphasis, factor: CGFloat(factor)) {
                    _ = builder.addFont(font, onRange: style.range)
                }
            case .color(let hexString):
                _ = builder.addColor(UIColor.fromHex(hexString.replace("#", "")), onRange: style.range)
            case .underline:
                _ = builder.addUnderline(onRange: style.range)
            case .link(let linkUrl):
                _ = builder.addLink(linkUrl, onRange: style.range)
                let linkAttributes = styles
                    .filter { $0.range == style.range }
                    .map { $0.attribute }
                    .attributes(withFont: font, color: component.componentTextColor)
                component.linkAttributes = linkAttributes
            }
        }
        return builder
            .addAlignment(configuration.alignment ?? component.textAlignment)
            .addLineBreakMode(configuration.lineBreakMode ?? component.lineBreakMode)
            .addLineHeightMultiple(configuration.lineHeightMultiple ?? 0.0)
            .build()
    }
}

public extension Array where Element == StyleType {
    
    func attributes(withFont font: UIFont, color: UIColor?) -> [NSAttributedString.Key: Any] {
        var attributes: [(NSAttributedString.Key, Any)] = []
        attributes.append((.underlineStyle, NSUnderlineStyle.single.rawValue))
        attributes.append(contentsOf: compactMap {
            switch $0 {
            case .font(emphasis: let emphasis, factor: let factor):
                guard let font = font.font(with: emphasis, factor: CGFloat(factor)) else { return nil }
                return (.font, font)
            case .color(hex: let hexString):
                return (.foregroundColor, UIColor.fromHex(hexString.replace("#", "")))
            case .underline:
                return nil
            case .link:
                return nil
            }
        })
        if !attributes.contains(where: { $0.0 == .foregroundColor }) {
            attributes.append((.foregroundColor, color as Any))
        }
        return Dictionary(uniqueKeysWithValues: attributes)
    }
}
