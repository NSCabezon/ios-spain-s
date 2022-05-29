//
//  StylesManager.swift
//  RetailLegacy
//
//  Created by Ernesto Fernandez Calles on 20/4/21.
//

import Foundation
import CoreFoundationLib

extension NormalizedStyling {
    
    init?(style: StylesManager.StringStyling) {
        let start = style.startPosition
        let length = style.length
        switch style.attribute {
        case .underline:
            self.init(start: start, length: length, attribute: .underline)
        case .color:
            guard let hex = style.extra else {
                return nil
            }
            self.init(start: start, length: length, attribute: .color(hex: hex))
        case .link:
            guard let link = style.extra else {
                return nil
            }
            self.init(start: start, length: length, attribute: .link(link))
        default:
            return nil
        }
    }
}

final public class StylesManager {
    
    private static var pattern: NSRegularExpression = {
        do {
            return try NSRegularExpression(pattern: "\\{\\{([^\\{\\}:]+):?([^\\{\\}]+)?\\}\\}")
        } catch let error {
            RetailLogger.e(String(describing: type(of: StylesManager.self)), "Invalid regular expression: \(error.localizedDescription). Dying.")
            fatalError()
        }
    }()
    
    public init() {}
    
    struct StringStyling {
        enum StyleAttribute: String {
            case bold
            case italic
            case size
            case color
            case underline
            case link
        }
        
        var startPosition: Int
        var endPosition = -1
        var length: Int {
            return endPosition - startPosition
        }
        var extra: String?
        var attribute: StyleAttribute
        var numberFormatter: NumberFormatter {
            let numberFormatter = NumberFormatter()
            numberFormatter.decimalSeparator = "."
            return numberFormatter
        }
        
        init(startPosition: Int, extra: String?, attribute: StyleAttribute) {
            self.startPosition = startPosition
            self.extra = extra
            self.attribute = attribute
        }
    }
    
    class func replacePlaceholder(_ originalString: String, _ stringPlaceholder: [StringPlaceholder]) -> String {
        var replacedString = originalString
        for placeholder in stringPlaceholder {
            replacedString = replacedString.replaceFirst(placeholder.placeholder, placeholder.replacement)
        }
        return replacedString
    }
    
    class func processStyles(in text: String) -> LocalizedStylableText {
        var text = text
        let styles = normalizeStyles(styles: findStyles(text: text))
        text = cleanStyles(in: text)
        return LocalizedStylableText(text: text, styles: styles)
    }
    
    private class func normalizeStyles(styles: [StringStyling]) -> [NormalizedStyling]? {
        let fontRelatedTypes: [StringStyling.StyleAttribute] = [.bold, .italic, .size]
        let fontRelatedStyles = styles.filter {
            return fontRelatedTypes.contains($0.attribute)
        }
        let rest = styles.filter {
            return !fontRelatedTypes.contains($0.attribute)
        }.compactMap {
            NormalizedStyling(style: $0)
        }
        let result = join(fonts: fontRelatedStyles) + rest
        return result.isEmpty ? nil : result
    }
    
    private class func join(fonts: [StringStyling]) -> [NormalizedStyling] {
        
        func createNormalizedFonts(from fontsByRange: [NSRange: [StringStyling]]) -> [NormalizedStyling] {
            var normalizedFonts = [NormalizedStyling]()
            for range in fontsByRange.keys {
                guard let fontsOfRange = fontsByRange[range] else {
                    continue
                }
                var fontEmphasis = ""
                var fontFactor: Float = 1.0
                if !fontsOfRange.filter({ $0.attribute == .bold }).isEmpty {
                    fontEmphasis = "Bold"
                }
                if !fontsOfRange.filter({ $0.attribute == .italic }).isEmpty {
                    fontEmphasis += "Italic"
                }
                if let size = fontsOfRange.first(where: { $0.attribute == .size }) {
                    if let factor = size.extra, let conversion = size.numberFormatter.number(from: factor) {
                        fontFactor = conversion.floatValue
                    }
                }
                let emphasisType = FontEmphasis(rawValue: fontEmphasis) ?? .regular
                let styleType = StyleType.font(emphasis: emphasisType, factor: fontFactor)
                normalizedFonts += [NormalizedStyling(start: range.location, length: range.length, attribute: styleType)]
            }
            return normalizedFonts
        }
        
        var fonts = fonts.sorted {
            $0.startPosition < $1.startPosition
        }
        var fontsByRange = [NSRange: [StringStyling]]()
        for indexFor in 0..<fonts.count {
            let font = fonts[indexFor]
            var fontRange = NSRange(location: font.startPosition, length: font.length)
            var indexWhile = indexFor + 1
            let validRange = fontRange.length > 0
            let otherFontsToCompare = indexWhile < fonts.count
            if otherFontsToCompare && validRange {
                while indexWhile < fonts.count {
                    var otherFont = fonts[indexWhile]
                    let otherRange = NSRange(location: otherFont.startPosition, length: otherFont.length)
                    if let intersection = fontRange.intersection(otherRange) {
                        fontRange.length = intersection.location - fontRange.location
                        otherFont.startPosition = intersection.location + intersection.length
                        fonts[indexWhile] = otherFont
                        var intersectedFonts = fontsByRange[intersection] ?? [font]
                        intersectedFonts += [otherFont]
                        fontsByRange[intersection] = intersectedFonts
                    }
                    indexWhile += 1
                }
            }
            if fontRange.length > 0 {
                var fontsOfRange = fontsByRange[fontRange] ?? []
                fontsOfRange += [font]
                fontsByRange[fontRange] = fontsOfRange
            }
        }
        return createNormalizedFonts(from: fontsByRange)
    }
    
    private class func findStyles(text: String) -> [StringStyling] {
        var text = text
        var stylingTable = [String: StringStyling]()
        var styles = [StringStyling]()
        while let match = pattern.firstMatch(in: text, options: [], range: NSRange(text.startIndex..., in: text)) {
            guard var tag = text.substring(with: match.range(at: 1)) else {
                return []
            }
            let extra = text.substring(with: match.range(at: 2))
            if tag.starts(with: "/") == true {
                //closing tag
                tag = tag.replace("/", "")
                
                if stylingTable.keys.contains(tag), var stringStyling = stylingTable[tag] {
                    stringStyling.endPosition = match.range.location
                    styles.append(stringStyling)
                    stylingTable.removeValue(forKey: tag)
                }
            } else if let attribute = StringStyling.StyleAttribute(rawValue: tag.lowercased()) {
                stylingTable[tag] = StringStyling(startPosition: match.range.location, extra: extra, attribute: attribute)
            }
            guard let range = Range(match.range, in: text) else {
                return []
            }
            text = text.replacingCharacters(in: range, with: "")
        }
        for tag in stylingTable.keys {
            guard var stringStyling = stylingTable[tag] else {
                continue
            }
            stringStyling.endPosition = text.count
            styles.append(stringStyling)
        }
        return styles
    }
    
    private class func cleanStyles(in text: String) -> String {
        return pattern.stringByReplacingMatches(in: text, options: [], range: NSRange(text.startIndex..., in: text), withTemplate: "")
    }
}

extension StylesManager: StylesLoader {
    public func applyStyles(to string: String) -> LocalizedStylableText {
        return applyStyles(to: string, [])
    }

    public func applyStyles(to string: String, _ stringPlaceHolder: [StringPlaceholder]) -> LocalizedStylableText {
        let temp = StylesManager.replacePlaceholder(string, stringPlaceHolder)
        return StylesManager.processStyles(in: temp)
    }
}
