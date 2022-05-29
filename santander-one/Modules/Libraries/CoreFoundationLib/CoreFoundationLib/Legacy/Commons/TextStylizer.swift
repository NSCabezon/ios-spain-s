//
//  TextStylizer.swift
//  Commons
//
//  Created by Juan Carlos López Robles on 10/15/19.
//

import Foundation

public class TextStylizer {
    
    public class Builder {
        let fullText: String
        var parts = [TextStyle]()
        
        public init(fullText: String) {
            self.fullText = fullText
        }
        
        public func addPartStyle(part: TextStyle) -> Builder {
            parts.append(part)
            return self
        }
        
        public func build() -> NSAttributedString {
            let attributedString = NSMutableAttributedString(string: fullText)
            for part in parts {
                part.build(attributedString: attributedString)
            }
            return attributedString
        }
        
        public class TextStyle {
            var color: UIColor?
            var backgroundColor: UIColor?
            var size: CGFloat?
            var style: UIFont?
            var typeFace: String?
            var text: String
            var paragraphStyle: NSParagraphStyle?
            
            public init(word: String) {
                self.text = word
            }
            
            public func setColor(_ color: UIColor) -> Self {
                self.color = color
                return self
            }
            
            public func setBackgroundColor(_ backgroundColor: UIColor) -> Self {
                self.backgroundColor = backgroundColor
                return self
            }
            
            public func setSize(_ size: CGFloat) -> Self {
                self.size = size
                return self
            }
            
            public func setStyle(_ style: UIFont) -> Self {
                self.style = style
                return self
            }
            
            public func setTypeFace(_ typeFace: String) -> Self {
                self.typeFace = typeFace
                return self
            }
            
            public func setParagraphStyle(_ style: NSParagraphStyle) -> Self {
                self.paragraphStyle = style
                return self
            }
            
            public func build(attributedString: NSMutableAttributedString) {
                
                if let range = attributedString.rangeOf(string: text) {
                    var attributes = [NSAttributedString.Key: Any]()
                    if let color = color {
                        attributes[.foregroundColor] = color
                    }
                    
                    if let backgroundColor = backgroundColor {
                        attributes[.backgroundColor] = backgroundColor
                    }
                    
                    if let size = size, style == nil, typeFace == nil {
                        attributes[.font] = UIFont.systemFont(ofSize: size) // FONT SIZE WITH DEFAULT FONT
                    }
                    
                    if let style = style, typeFace == nil {
                        attributes[.font] = style // FONT STYLE
                    }
                    
                    if let typeFace = typeFace {
                        attributes[.font] = UIFont(name: typeFace, size: size ?? UIFont.systemFontSize)
                    }
                    
                    if let paragraphStyle = self.paragraphStyle {
                        attributes[.paragraphStyle] = paragraphStyle
                    }
                    
                    attributedString.addAttributes(attributes, range: NSRange(range, in: attributedString.string))
                }
                
            }
        }
        
    }
}
