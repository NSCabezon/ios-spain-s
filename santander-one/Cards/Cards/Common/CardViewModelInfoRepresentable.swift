//
//  CardViewModelInfoRepresentable.swift
//  Cards
//
//  Created by Boris Chirino Fernandez on 07/10/2020.
//

import Foundation

import CoreFoundationLib

public protocol CardViewModelInfoRepresentable {
    var cardEntity: CardEntity { get }
    var expirationDateFormatted: String? { get }
    var tintColor: UIColor { get }
    var alias: String? { get }
    var pan: String? { get }
    var ownerFullName: String? { get }
    var cardTextColorEntity: [CardTextColorEntity] { get }
    var fullCardImageStringUrl: String? { get }
}

extension CardViewModelInfoRepresentable {
    public var expirationDateFormatted: String? {
        guard let stringDate = cardEntity.expirationDate else { return nil }
        let firstRange = stringDate.index(stringDate.endIndex, offsetBy: -4)...stringDate.index(stringDate.endIndex, offsetBy: -3)
        let secondRange = stringDate.index(stringDate.endIndex, offsetBy: -2)...stringDate.index(before: stringDate.endIndex)
        let year = stringDate[firstRange]
        let month = stringDate[secondRange]
        return month + "/" + year
    }
    
    public var tintColor: UIColor {
        if cardEntity.inactive || cardEntity.isDisabled {
            return .coolGray
        }
        guard let visualCode = cardEntity.visualCode else {
            return .white
        }
        let visualCodeInPreferences =  self.cardTextColorEntity.contains(where: {$0.cardCode == visualCode})
        return visualCodeInPreferences ? .black : .white
    }
    
    public var alias: String? {
        return cardEntity.alias
    }
    
    var pan: String? {
        return cardEntity.detailUI
    }
    
    public var ownerFullName: String? {
        return cardEntity.stampedName
    }
}
