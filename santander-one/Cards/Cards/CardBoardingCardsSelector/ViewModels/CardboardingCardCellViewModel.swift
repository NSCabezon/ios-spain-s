//
//  CardboardingCardCellViewModel.swift
//  Cards
//
//  Created by Boris Chirino Fernandez on 19/01/2021.
//

import CoreFoundationLib

struct CardboardingCardCellViewModel {
    public let entity: CardEntity
    private let baseUrl: String
    
    var imgURL: String {
        return self.baseUrl + self.entity.cardImageUrl()
    }
    var disabled: Bool {
        return self.entity.isDisabled
    }
    var isInactive: Bool {
        return self.entity.inactive
    }
    var title: String {
        return self.entity.alias ?? ""
    }
    var subtitle: String {
        let typeCard = self.entity.cardType.keyGP
        let placeholder = StringPlaceholder(.value, self.entity.shortContract)
        let subtitleText = localized(typeCard, [placeholder]).text
        return subtitleText
    }
    var formattedPAN: String? {
        entity.formattedPAN
    }
    
    func isInstanceEntityEqualTo(_ entity: CardEntity) -> Bool {
        return entity == self.entity
    }
    
    public init(cardEntity: CardEntity, baseUrl: String) {
        self.entity = cardEntity
        self.baseUrl = baseUrl
    }
}
