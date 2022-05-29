//
//  BizumDefaultNGOsRepositoryProtocol.swift
//  RetailLegacy
//
//  Created by Carlos Monfort Gómez on 16/02/2021.
//

import Foundation


public protocol BizumDefaultNGOsRepositoryProtocol {
    func getDefaultNGOs() -> BizumDefaultNGOsListDTO?
    func load(baseUrl: String, language: PublicLanguage)
}
