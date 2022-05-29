//
//  LocalizedStylableText.swift
//  Commons
//
//  Created by Jose Carlos Estela Anguita on 14/10/2019.
//

import Foundation

public enum GrammarNumber {
    case singular
    case plural
}

public struct LocalizedStylableText {
    public static var empty = LocalizedStylableText(text: "", styles: nil)
    
    @available(*, deprecated, message: "Use text instead")
    public var plainText: String {
        self.text
    }
    public var text: String
    public var styles: [NormalizedStyling]?
    
    public init(text: String, styles: [NormalizedStyling]?) {
        self.text = text
        self.styles = styles
        self.text = text
    }

    public static func plain(text: String?) -> LocalizedStylableText {
        return LocalizedStylableText(text: text ?? "", styles: nil)
    }

    public func uppercased() -> LocalizedStylableText {
        var uppercased = self
        uppercased.text = text.uppercased()
        return uppercased
    }

    public mutating func camelCased() -> LocalizedStylableText {
        var camelCased = self
        camelCased.text = text.capitalized
        return camelCased
    }
    
    public mutating func capitalizedBySentence() -> LocalizedStylableText {
        var capitalizedSentence = self
        capitalizedSentence.text = text.capitalizedBySentence()
        return capitalizedSentence
    }
}

public enum StyleType {
    case font(emphasis: FontEmphasis, factor: Float)
    case color(hex: String)
    case underline
    case link(String)
}

public enum FontEmphasis: String {
    case bold = "Bold"
    case boldItalic = "BoldItalic"
    case italic = "Italic"
    case regular = "Regular"
}

public struct NormalizedStyling {
    
    public let range: NSRange
    public var attribute: StyleType

    public init(start: Int, length: Int, attribute: StyleType) {
        self.range = NSRange(location: start, length: length)
        self.attribute = attribute
    }
}
