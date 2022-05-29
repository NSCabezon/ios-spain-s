//
//  StylesLoader.swift
//  RetailLegacy
//
//  Created by Ernesto Fernandez Calles on 20/4/21.
//

public protocol StylesLoader {
    
    func applyStyles(to string: String) -> LocalizedStylableText
    
    func applyStyles(to string: String, _ stringPlaceholders: [StringPlaceholder]) -> LocalizedStylableText
}
