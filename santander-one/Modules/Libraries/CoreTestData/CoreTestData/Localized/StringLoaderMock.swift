//
//  StringLoaderMock.swift
//  Loans-Unit-LoansTests
//
//  Created by Jose Carlos Estela Anguita on 15/10/2019.
//

import Foundation
import CoreFoundationLib

public class StringLoaderMock: StringLoader {
    public init() {}
    
    public func getWsErrorIfPresent(_ key: String) -> LocalizedStylableText? {
        return .empty
    }
    
    public func updateCurrentLanguage(language: Language) {
        
    }
    
    public func getCurrentLanguage() -> Language {
        return .createDefault(isPb: false, defaultLanguage: .spanish, availableLanguageList: [.spanish])
    }
    
    public func getString(_ key: String) -> LocalizedStylableText {
        return .empty
    }
    
    public func getString(_ key: String, _ stringPlaceholders: [StringPlaceholder]) -> LocalizedStylableText {
        return .empty
    }
    
    public func getQuantityString(_ key: String, _ count: Int, _ stringPlaceholders: [StringPlaceholder]) -> LocalizedStylableText {
        return .empty
    }
    
    public func getQuantityString(_ key: String, _ count: Double, _ stringPlaceholders: [StringPlaceholder]) -> LocalizedStylableText {
        return .empty
    }
    
    public func getWsErrorString(_ key: String) -> LocalizedStylableText {
        return .empty
    }
    
    public func getWsErrorWithNumber(_ key: String, _ phone: String) -> LocalizedStylableText {
        return .empty
    }
    
}
