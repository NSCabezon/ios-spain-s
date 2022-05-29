//
// Created by SYS_CIBER_ADMIN on 27/2/18.
// Copyright (c) 2018 Ciber. All rights reserved.
//

import UIKit

extension NSAttributedString {
    
    static func lineSpacing(_ text: String, _ lineSpacing: CGFloat, _ alignment: NSTextAlignment) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: text)
        
        // *** Create instance of `NSMutableParagraphStyle`
        let paragraphStyle = NSMutableParagraphStyle()
        
        // *** set LineSpacing property in points ***
        paragraphStyle.lineSpacing = lineSpacing // Whatever line spacing you want in points
        paragraphStyle.alignment = alignment
        // *** Apply attribute to string ***
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedString.length))
        
        // *** Set Attributed String to your label ***
        return attributedString
    }
    
    static func underline(with string: String, color: UIColor) -> NSAttributedString {
        return NSAttributedString(string: string,
                                  attributes: [.underlineStyle: NSUnderlineStyle.single,
                                               .underlineColor: color])
    }
}

enum AttributeType {
    case font(UIFont)
    case color(UIColor)
    case paragraphStyle(NSParagraphStyle)
}

extension NSAttributedString {
    func rangeOf(string: String) -> Range<String.Index>? {
        return self.string.range(of: string)
    }
    
    func getTextSize() -> CGSize {
        let testLabel = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: 0, height: 0))
        testLabel.attributedText = self
        testLabel.sizeToFit()
        return testLabel.frame.size
    }
}
