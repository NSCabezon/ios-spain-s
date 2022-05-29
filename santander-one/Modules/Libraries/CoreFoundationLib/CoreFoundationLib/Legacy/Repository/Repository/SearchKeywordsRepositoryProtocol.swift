//
//  SearchKeywordsRepositoryProtocol.swift
//  Repository
//
//  Created by César González Palomino on 25/07/2020.
//



public protocol SearchKeywordsRepositoryProtocol {
    func getKeywords() -> SearchKeywordListDTO?
    func load(baseUrl: String, publicLanguage: PublicLanguage)
}
