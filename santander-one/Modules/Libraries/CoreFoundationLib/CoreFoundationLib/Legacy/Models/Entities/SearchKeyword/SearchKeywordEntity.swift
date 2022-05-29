//
//  SearchKeywordEntity.swift
//  Models
//
//  Created by César González Palomino on 25/07/2020.
//

import Foundation

public final class SearchKeywordEntity: DTOInstantiable {
    public let dto: SearchKeywordDTO
    
    public init(_ dto: SearchKeywordDTO) {
        self.dto = dto
    }
    
    public var word: String { dto.word }
    public var  lexeme: String { dto.lexeme }
    public var errorWords: [String] { dto.errorWords }
}
