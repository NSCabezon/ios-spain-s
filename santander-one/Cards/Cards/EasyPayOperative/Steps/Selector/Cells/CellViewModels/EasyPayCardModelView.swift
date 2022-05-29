//
//  EasyPayCardModelView.swift
//  Cards
//
//  Created by alvola on 14/12/2020.
//
import CoreFoundationLib
import UI

final class EasyPayCardModelView {
    private let card: CardEntity
    private let transaction: CardTransactionEntity
    
    let identifier = "EasyPayCardTableViewCell"
    
    init(card: CardEntity, transaction: CardTransactionEntity) {
        self.card = card
        self.transaction = transaction
    }
    
    var imageURL: String {
        return card.buildImageRelativeUrl(miniature: true)
    }
    
    var imagePlaceholder = "defaultCard"
    
    var title: String? {
        return transaction.description?.capitalized
    }
    
    var amount: String? {
        return transaction.amount?.getFormattedAmountUI()
    }
}

extension EasyPayCardModelView: EasyPayTableViewModelProtocol { }
