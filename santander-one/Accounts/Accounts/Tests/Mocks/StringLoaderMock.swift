//
//  StringLoaderMock.swift
//  Loans-Unit-LoansTests
//
//  Created by Jose Carlos Estela Anguita on 15/10/2019.
//

import Foundation
import CoreFoundationLib

class StringLoaderMock: StringLoader {
    
    func updateCurrentLanguage(language: Language) {
        
    }
    
    func getCurrentLanguage() -> Language {
        return .createDefault(isPb: false)
    }
    
    func getString(_ key: String) -> LocalizedStylableText {
        return .empty
    }
    
    func getString(_ key: String, _ stringPlaceholders: [StringPlaceholder]) -> LocalizedStylableText {
        return .empty
    }
    
    func getQuantityString(_ key: String, _ count: Int, _ stringPlaceholders: [StringPlaceholder]) -> LocalizedStylableText {
        return .empty
    }
    
    func getQuantityString(_ key: String, _ count: Double, _ stringPlaceholders: [StringPlaceholder]) -> LocalizedStylableText {
        return .empty
    }
    
    func getWsErrorString(_ key: String) -> LocalizedStylableText {
        return .empty
    }
    
    func getWsErrorWithNumber(_ key: String, _ phone: String) -> LocalizedStylableText {
        return .empty
    }
    
}
