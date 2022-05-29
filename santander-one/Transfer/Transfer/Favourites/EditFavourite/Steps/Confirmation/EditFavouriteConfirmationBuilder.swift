//
//  EditFavouriteConfirmationBuilder.swift
//  Account
//
//  Created by Jose Enrique Montero Prieto on 27/07/2021.
//

import CoreFoundationLib
import Operative

final class EditFavouriteConfirmationBuilder {
    var items: [ConfirmationItemViewModel] = []
    let operativeData: EditFavouriteOperativeData
    let dependenciesResolver: DependenciesResolver
    
    init(operativeData: EditFavouriteOperativeData, dependenciesResolver: DependenciesResolver) {
        self.operativeData = operativeData
        self.dependenciesResolver = dependenciesResolver
    }
    
    func addAlias() {
        let name = self.operativeData.selectedFavourite?.payeeDisplayName ?? ""
        let item = ConfirmationItemViewModel(
            title: localized("pt_cross_hint_saveFavoriteName"),
            value: name.capitalized
        )
        self.items.append(item)
    }
    
    func addBeneficiary() {
        let name = self.operativeData.newBeneficiaryName ?? ""
        let item = ConfirmationItemViewModel(
            title: localized("sendMoney_label_recipients"),
            value: name.capitalized
        )
        self.items.append(item)
    }
    
    func addIban() {
        let name = self.operativeData.newDestinationAccount?.ibanPapel ?? ""
        let item = ConfirmationItemViewModel(
            title: localized("sendMoney_label_iban"),
            value: name
        )
        self.items.append(item)
    }
    
    func addCountryDestination() {
        guard let country = self.operativeData.currentCountry?.name,
              let currency = self.operativeData.currentCurrency?.name
        else { return }
        let name = country + " - " + currency
        let item = ConfirmationItemViewModel(
            title: localized("confirmation_item_destinationCountry"),
            value: name.capitalized, position: .last
        )
        self.items.append(item)
    }
    
    func build() -> [ConfirmationItemViewModel] {
        return self.items
    }
}
