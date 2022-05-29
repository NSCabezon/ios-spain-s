//
//  PGCommonTexts.swift
//  GlobalPosition
//
//  Created by Boris Chirino Fernandez on 02/04/2020.
//

import Foundation
import CoreFoundationLib

public enum PGComonTextElements {
    case classicGeneralProductCell(GrammarNumber)
    case classicCardFooterCell(GrammarNumber)
}

public struct PGCommonTexts {
    static func localizableTextForElement(_ element: PGComonTextElements, placeHolder: StringPlaceholder? = nil) -> LocalizedStylableText {
        switch element {
        case .classicGeneralProductCell(let grammar):
            return localizedFor(grammar == .singular ? "pgBasket_label_transaction_one" : "pgBasket_label_transaction_other", placeHolder: placeHolder)
        case .classicCardFooterCell(let grammar):
            return localizedFor(grammar == .singular ? "pgBasket_label_cards_one" : "pgBasket_label_cards_other", placeHolder: placeHolder)
        }
    }
   
   private static func localizedFor(_ key: String, placeHolder: StringPlaceholder?) -> LocalizedStylableText {
        if let optionalPlaceHolder = placeHolder {
               return localized(key, [optionalPlaceHolder])
        } else {
            return localized(key)
        }
    }
}
