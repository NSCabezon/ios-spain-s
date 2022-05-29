//
//  EditFavouriteOperativeData.swift
//  Transfer
//
//  Created by Jose Enrique Montero Prieto on 19/07/2021.
//

import CoreDomain
import Foundation
import CoreFoundationLib

final class EditFavouriteOperativeData {
    var selectedFavourite: PayeeRepresentable?
    var currentCountry: SepaCountryInfoEntity?
    var currentCurrency: SepaCurrencyInfoEntity? = SepaCurrencyInfoEntity.createEuro()
    var newBeneficiaryName: String?
    var newDestinationAccount: IBANEntity?
    var selectedFavouriteType: FavoriteType?
    
    init(favoriteType: FavoriteType) {
        self.currentCountry = self.createPortugal()
        self.selectedFavourite = favoriteType.favorite
        self.selectedFavouriteType = favoriteType
    }
    
}

private extension EditFavouriteOperativeData {
    func createPortugal() -> SepaCountryInfoEntity {
        let dto = CountryInfoDTO(code: "PT", name: "Portugal", currency: "EUR", bbanLength: 21, sepa: true, fxpay: true, isAlphanumeric: false)
        return SepaCountryInfoEntity(dto)
    }
}
