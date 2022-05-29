import UIKit

public final class AttributedStringBuilder {
    var attributedString: NSMutableAttributedString
    var paragraphStyle: NSMutableParagraphStyle!
    
    private var completeRange: NSRange {
        return NSRange(location: 0, length: attributedString.string.count)
    }
    
    public init(attributedString: NSAttributedString) {
        self.attributedString = NSMutableAttributedString(attributedString: attributedString)
        attributedString.enumerateAttribute(.paragraphStyle, in: NSRange(location: 0, length: attributedString.string.count), options: .longestEffectiveRangeNotRequired) { (paragraph, _, _) in
            self.paragraphStyle = (paragraph as? NSMutableParagraphStyle) ?? NSMutableParagraphStyle()
        }
    }
    
    public init(string: String, properties: [NSAttributedString.Key: Any]? = nil) {
        self.attributedString = NSMutableAttributedString(string: string, attributes: properties)
        if let paragraph = properties?[NSAttributedString.Key.paragraphStyle] as? NSMutableParagraphStyle {
            self.paragraphStyle = paragraph
        } else {
            self.paragraphStyle = NSMutableParagraphStyle()
        }
    }
    
    public func addFont(_ font: UIFont, onRange range: NSRange? = nil) -> Self {
        let usedRange = range ?? completeRange
        attributedString.addAttribute(.font, value: font, range: usedRange)
        return self
    }
    
    public func addColor(_ color: UIColor, onRange range: NSRange? = nil) -> Self {
        let usedRange = range ?? completeRange
        attributedString.addAttribute(.foregroundColor, value: color, range: usedRange)
        return self
    }
    
    public func addUnderline(onRange range: NSRange? = nil) -> Self {
        let usedRange = range ?? completeRange
        attributedString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: usedRange)
        return self
    }
    
    public func addLink(_ link: String, onRange range: NSRange) -> Self {
        attributedString.addAttribute(.link, value: link as NSString, range: range)
        return self
    }
    
    public func addAlignment(_ alignment: NSTextAlignment) -> Self {
        paragraphStyle.alignment = alignment
        return self
    }
    
    public func addLineHeightMultiple(_ lineHeightMultiple: CGFloat) -> Self {
        paragraphStyle.lineHeightMultiple = lineHeightMultiple
        return self
    }
    
    public func addLineBreakMode(_ lineBreakMode: NSLineBreakMode) -> Self {
        paragraphStyle.lineBreakMode = lineBreakMode
        return self
    }
    
    public func build() -> NSAttributedString {
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle as NSMutableParagraphStyle, range: completeRange)
        return attributedString
    }
}
