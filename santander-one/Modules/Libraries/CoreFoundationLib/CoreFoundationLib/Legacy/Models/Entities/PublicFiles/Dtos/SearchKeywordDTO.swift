//
//  SearchKeywordDTO.swift
//  Models
//
//  Created by César González Palomino on 25/07/2020.
//

public struct SearchKeywordDTO: Codable {
    public let word: String
    public let lexeme: String
    public let errorWords: [String]
    
    public init(word: String,
                currency: String,
                lexeme: String,
                errorWords: [String]) {
        self.word = word
        self.lexeme = lexeme
        self.errorWords = errorWords
    }
}
