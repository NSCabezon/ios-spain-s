//
//  CharacterSet+Extension.swift
//  CoreFoundationLib
//
//  Created by Jose Ignacio de Juan Díaz on 31/1/22.
//

import Foundation

public extension CharacterSet {
    
    static var signature: CharacterSet {
        return CharacterSet(charactersIn: "1234567890qwertyuiopasdfghjklñzxcvbnmQWERTYUIOPÑLKJHGFDSAZXCVBNM")
    }
    
    static var iban: CharacterSet {
        return CharacterSet(charactersIn: localized("digits_iban_or_similar"))
    }
    
    static var operative: CharacterSet {
        return CharacterSet(charactersIn: localized("digits_operative"))
    }

    static var email: CharacterSet {
        var charSet = CharacterSet(charactersIn: localized("digits_operative"))
        charSet.insert("@")
        return charSet
    }
    
    static var ibanNoSepa: CharacterSet {
        return CharacterSet(charactersIn: localized("digits_iban_or_similar"))
    }
    
    static var search: CharacterSet {
        return CharacterSet(charactersIn: localized("digits_operative"))
    }
    
    static var alias: CharacterSet {
        return CharacterSet(charactersIn: localized("digits"))
    }

    static var bizumConcept: CharacterSet {
        return CharacterSet(charactersIn: localized("digits_bizum_operative"))
    }
    
    static var custom: CharacterSet {
        return CharacterSet(charactersIn: "1234567890qwertyuiopasdfghjklñzxcvbnmQWERTYUIOPÑLKJHGFDSAZXCVBNM _,.:-?/()+áéíóúÁÉÍÓÚÇç'")
    }
    
    static var numbers: CharacterSet {
        return CharacterSet(charactersIn: "1234567890")
    }
    
    static var sendMoneyOperative: CharacterSet {
        return CharacterSet(charactersIn: localized("digits_sendMoney_operative"))
    }
}

