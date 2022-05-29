//
//  OneFavoriteContactCardViewModel.swift
//  Models
//
//  Created by Juan Diego Vázquez Moreno on 3/9/21.
//

import CoreDomain

public final class OneFavoriteContactCardViewModel {
    public var cardStatus: CardStatus
    public let avatar: OneAvatarViewModel
    public let payee: PayeeRepresentable
    private let dependenciesResolver: DependenciesResolver

    public init(
        cardStatus: CardStatus,
        avatar: OneAvatarViewModel,
        payee: PayeeRepresentable,
        dependenciesResolver: DependenciesResolver
    ) {
        self.cardStatus = cardStatus
        self.avatar = avatar
        self.payee = payee
        self.dependenciesResolver = dependenciesResolver
    }
}

public extension OneFavoriteContactCardViewModel {
    enum CardStatus {
        case inactive
        case selected
    }

    var name: String {
        return payee.payeeDisplayName?.camelCasedString ?? ""
    }
    
    var shortIBAN: String {
        guard !payee.shortIBAN.isEmpty else {
            return payee.shortAccountNumber ?? ""
        }
        return payee.shortIBAN
    }
    
    var ibanPapel: String {
        return payee.ibanPapel
    }
    
    var bankLogoURL: String? {
        let baseURLProvider: BaseURLProvider = self.dependenciesResolver.resolve()
        guard let entityCode = self.payee.entityCode,
              let countryCode = self.payee.countryCode,
              let baseURL = baseURLProvider.baseURL
        else { return nil }
        return String(format: "%@%@/%@_%@%@",
                      baseURL,
                      GenericConstants.relativeURl,
                      countryCode.lowercased(),
                      entityCode,
                      GenericConstants.iconBankExtension)
    }
}
