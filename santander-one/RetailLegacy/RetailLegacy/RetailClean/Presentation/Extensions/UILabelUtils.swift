import UIKit

extension UILabel {
    func scaleDecimals() {
        if let text = self.text {
            if text.isEmpty || text.contains("M") {
                self.attributedText = NSAttributedString(string: text)
            } else if let position = text.distanceFromStart(to: ",") {
                let decimalPart = text.substring(with: NSRange(location: position, length: text.count - position))!
                let builder = TextStylizer.Builder(fullText: text)
                self.attributedText = builder.addPartStyle(part: TextStylizer.Builder.TextStyle(word: decimalPart).setStyle(self.font.withSize(self.font.pointSize * 0.75)))
                    .build()
            }
        }
    }
    
    func setVariation(variation: String?, compareZero: ComparisonResult, withParenthesis: Bool = false) {
        if let change = variation {
            let color: UIColor
            let text: String
            switch compareZero {
            case .orderedDescending:
                text = withParenthesis ? "(\(change)%)" : "\(change)%"
                color = .sanRed
            case .orderedAscending:
                text = withParenthesis ? "(+\(change)%)" : "+\(change)%"
                color = .green
            case .orderedSame:
                text = withParenthesis ? "(-\(change)%)" : "-\(change)%"
                color = .sanGrey
            }
            self.text = text
            self.textColor = color
        } else {
            self.text = nil
        }
    }
    
    func calculateMaxLines() -> Int {
        let maxSize = CGSize(width: frame.size.width, height: CGFloat(Float.infinity))
        let charSize = font.lineHeight
        let text = (self.text ?? "") as NSString
        let textSize = text.boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: [.font: font as Any], context: nil)
        let lines = Int(textSize.height/charSize)
        
        return lines
    }
    
    func set(lineSpacing: CGFloat) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing
        
        let attributed = attributedText ?? NSAttributedString(string: text ?? "")
        let mutable = NSMutableAttributedString(attributedString: attributed)
        mutable.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributed.string.count))
        
        let alignment = textAlignment
        attributedText = mutable
        
        textAlignment = alignment
    }
    
    func set(lineHeightMultiple: CGFloat) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineHeightMultiple
        paragraphStyle.lineHeightMultiple = lineHeightMultiple
        
        let attributed = attributedText ?? NSAttributedString(string: text ?? "")
        let mutable = NSMutableAttributedString(attributedString: attributed)
        mutable.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributed.string.count))
        
        let alignment = textAlignment
        attributedText = mutable
        
        textAlignment = alignment
    }
    
    func underline() {
        if let textString = self.text {
            let attributedString = NSMutableAttributedString(string: textString)
            attributedString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0, length: attributedString.length))
            attributedText = attributedString
        }
    }
}
