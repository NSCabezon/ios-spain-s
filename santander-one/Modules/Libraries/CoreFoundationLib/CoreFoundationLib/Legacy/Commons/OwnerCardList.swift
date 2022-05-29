//
//  OwnerCardList.swift
//  Commons
//
//  Created by Ignacio González Miró on 21/10/2020.
//

import Foundation

public struct OwnerCards {
    public var entity: CardEntity?
    public var urlString: String
    public var text: String
    public var number: LocalizedStylableText
    public var pan: String
    public var position: Int
    
    public init(_ entity: CardEntity?, urlString: String, text: String, number: LocalizedStylableText, pan: String, position: Int) {
        self.entity = entity
        self.urlString = urlString
        self.text = text
        self.number = number
        self.pan = pan
        self.position = position
    }
}
