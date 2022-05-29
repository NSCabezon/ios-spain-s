//
//  SpecialChars.swift
//  IOS-Pull-Offers
//
//  Created by Carlos Pérez Pérez on 11/7/18.
//  Copyright © 2018 Carlos Pérez Pérez. All rights reserved.
//

enum SpecialChars: String {
    case parenthesisLeft = "("
    case parenthesisRight = ")"
    case squareBracketLeft = "["
    case squareBracketRight = "]"
    case comma = ","
    case singleQuote = "'"
    case escapeQuote = "\""
    case space = " "

    static func parse(input: Character) -> SpecialChars? {
        switch input {
        case SpecialChars.parenthesisLeft.char:
            return .parenthesisLeft
        case SpecialChars.parenthesisRight.char:
            return .parenthesisRight
        case SpecialChars.squareBracketLeft.char:
            return .squareBracketLeft
        case SpecialChars.squareBracketRight.char:
            return .squareBracketRight
        case SpecialChars.comma.char:
            return .comma
        case SpecialChars.singleQuote.char:
            return .singleQuote
        case SpecialChars.escapeQuote.char:
            return .escapeQuote
        default:
            return nil
        }
    }
    
    var tokenType: TokenType? {
        switch self {
        case .parenthesisLeft:
            return .parenthesisLeft
        case .parenthesisRight:
            return .parenthesisRight
        case .squareBracketLeft:
            return .squareBracketLeft
        case .squareBracketRight:
            return .squareBracketRight
        case .comma:
            return .comma
        default:
            return nil
        }
    }
    
    var string: String {
        return self.rawValue
    }
    
    var char: Character {
        return self.rawValue.map({$0}).first!
    }
}
