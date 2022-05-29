//
//  CardSelectionViewModelProtocol.swift
//  Models
//
//  Created by Laura González on 27/05/2021.
//

protocol CardSelectionViewModelProtocol {
    var card: CardEntity { get }
    var alias: String { get }
    var cardId: String { get }
    var currentBalanceAmount: NSAttributedString { get }
}

extension CardSelectionViewModelProtocol {
    public var alias: String {
        return self.card.alias ?? ""
    }
    
    public var iban: String {
        return self.card.productId
    }
}
