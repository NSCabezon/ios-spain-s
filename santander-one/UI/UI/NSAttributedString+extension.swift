//
//  NSAttributedString+extension.swift
//  UI
//
//  Created by alvola on 21/05/2020.
//

import Foundation

extension NSAttributedString {
    public func highlight(_ text: String, in color: UIColor = .lightYellow) -> NSAttributedString {
        let ranges = self.string.ranges(of: text.trim()).map { NSRange($0, in: text) }

        return ranges.reduce(NSMutableAttributedString(attributedString: self)) {
            $0.addAttribute(.backgroundColor, value: UIColor.lightYellow, range: $1)
            return $0
        }
    }
}

extension NSMutableAttributedString {
    public func lineSpacing(_ lineSpacing: CGFloat, alignment: NSTextAlignment) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing
        paragraphStyle.alignment = alignment
        self.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: self.length))
    }
}

public enum AttributeType {
    case font(UIFont)
    case color(UIColor)
    case paragraphStyle(NSParagraphStyle)
}

extension NSMutableAttributedString {
    
    @discardableResult
    public func addAttributes(_ attributes: [AttributeType], to text: String? = nil) -> NSMutableAttributedString {
        attributes.forEach { addAttribute($0, to: text) }
        return self
    }
    
    @discardableResult
    public func addAttribute(_ attribute: AttributeType, to text: String? = nil) -> NSMutableAttributedString {
        guard let text = text, let range = self.string.range(of: text) else {
            return addAttribute(attribute, to: self.string)
        }
        switch attribute {
        case .font(let font):
            self.addAttribute(.font, value: font, range: NSRange(range, in: self.string))
        case .color(let color):
            self.addAttribute(.foregroundColor, value: color, range: NSRange(range, in: self.string))
        case .paragraphStyle(let paragraphStyle):
            self.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(range, in: self.string))
        }
        return self
    }
}

extension NSAttributedString {
    public func rangeOf(string: String) -> Range<String.Index>? {
        return self.string.range(of: string)
    }
    
    public func getTextSize() -> CGSize {
        let testLabel = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: 0, height: 0))
        testLabel.attributedText = self
        testLabel.sizeToFit()
        return testLabel.frame.size
    }
}
