//
//  PlasticCardViewModel.swift
//  Cards
//
//  Created by Boris Chirino Fernandez on 06/10/2020.
//

import CoreFoundationLib

public protocol PlasticCardModifierProtocol {
    func formatPAN(card: CardEntity) -> String?
    func formatOwnerName(fullname: String?) -> String?
}

class PlasticCardViewModel {
    private let entity: CardEntity
    private let textColorEntity: [CardTextColorEntity]
    private let baseUrl: String?
    private let dependenciesResolver: DependenciesResolver
    
    init(entity: CardEntity, textColorEntity: [CardTextColorEntity], baseUrl: String?, dependenciesResolver: DependenciesResolver) {
        self.entity = entity
        self.textColorEntity = textColorEntity
        self.baseUrl = baseUrl
        self.dependenciesResolver = dependenciesResolver
    }
}

extension PlasticCardViewModel: CardViewModelInfoRepresentable {
    var fullCardImageStringUrl: String? {
        guard let baseUrl = baseUrl else { return nil }
        return baseUrl + self.entity.cardImageUrl()
    }
    
    var cardEntity: CardEntity {
        self.entity
    }
    
    var cardTextColorEntity: [CardTextColorEntity] {
        self.textColorEntity
    }
    
    var tintColor: UIColor {
        guard let visualCode = cardEntity.visualCode else {
            return .white
        }
        let visualCodeInPreferences =  self.cardTextColorEntity.contains(where: {$0.cardCode == visualCode})
        return visualCodeInPreferences ? .black : .white
    }
    
    var pan: String? {
        guard let plasticCardModifier = self.dependenciesResolver.resolve(forOptionalType: PlasticCardModifierProtocol.self) else { return self.entity.pan }
        return plasticCardModifier.formatPAN(card: self.entity)
    }
    
    var ownerDisplayName: String? {
        guard let plasticCardModifier = self.dependenciesResolver.resolve(forOptionalType: PlasticCardModifierProtocol.self) else { return self.ownerFullName }
        return plasticCardModifier.formatOwnerName(fullname: self.ownerFullName)
    }
}
