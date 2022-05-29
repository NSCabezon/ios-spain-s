//
//  TextInputAttributes.swift
//  Commons
//
//  Created by Boris Chirino Fernandez on 9/6/21.
//

import Foundation

struct TextInputAttributes: IBANTextInputProtocol {
    var autocapitalizationType: UITextAutocapitalizationType = .allCharacters
    var keyboardType: UIKeyboardType = .default
    var bbaLenght: Int = 0
    var checkDigit: String?
    var validCharacterSet: CharacterSet = .iban
}
