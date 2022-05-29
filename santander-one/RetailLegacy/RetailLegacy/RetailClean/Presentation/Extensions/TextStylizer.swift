import UIKit

class TextStylizer {
    class Builder {
        let fullText: String
        var parts = [TextStyle]()
        
        init(fullText: String) {
            self.fullText = fullText
        }
        
        func addPartStyle(part: TextStyle) -> Builder {
            parts.append(part)
            return self
        }
        
        func build() -> NSAttributedString {
            let attributedString = NSMutableAttributedString(string: fullText)
            for part in parts {
                part.build(attributedString: attributedString)
            }
            return attributedString
        }
        
        class TextStyle {
            var color: UIColor?
            var backgroundColor: UIColor?
            var size: CGFloat?
            var style: UIFont?
            var typeFace: String?
            var text: String
            
            init(word: String) {
                self.text = word
            }
            
            func setColor(_ color: UIColor) -> Self {
                self.color = color
                return self
            }
            
            func setBackgroundColor(_ backgroundColor: UIColor) -> Self {
                self.backgroundColor = backgroundColor
                return self
            }
            
            func setSize(_ size: CGFloat) -> Self {
                self.size = size
                return self
            }
            
            func setStyle(_ style: UIFont) -> Self {
                self.style = style
                return self
            }
            
            func setTypeFace(_ typeFace: String) -> Self {
                self.typeFace = typeFace
                return self
            }
            
            func build(attributedString: NSMutableAttributedString) {
                if let range = attributedString.rangeOf(string: text) {
                    var attributes = [NSAttributedString.Key: Any]()
                    if let color = color {
                        attributes[.foregroundColor] = color
                    }
                    
                    if let backgroundColor = backgroundColor {
                        attributes[.backgroundColor] = backgroundColor
                    }
                    
                    if let size = size, style == nil, typeFace == nil {
                        attributes[.font] = UIFont.systemFont(ofSize: size) //FONT SIZE WITH DEFAULT FONT
                    }
                    
                    if let style = style, typeFace == nil {
                        attributes[.font] = style //FONT STYLE
                    }
                    
                    if let typeFace = typeFace {
                        attributes[.font] = UIFont(name: typeFace, size: size ?? UIFont.systemFontSize)
                    }
                    attributedString.addAttributes(attributes, range: NSRange(range, in: attributedString.string))
                }
                
            }
        }
        
    }
}
