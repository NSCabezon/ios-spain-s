//
//  SearchKeywordListDTO.swift
//  Models
//
//  Created by César González Palomino on 25/07/2020.
//

public struct SearchKeywordListDTO: Codable {
    public let searchKeywords: [SearchKeywordDTO]?
    public let globalAppKeywords: [GlobalAppKeywordsDTO]?
    public let operativesOnShorcutsAppKeywords: [OperativeOnShortcutsKeywordsDTO]?
    public let actionOnShorcutsAppKeywords: [GlobalAppKeywordsDTO]?
}
