import CoreFoundationLib
import Operative

final class NewFavouriteConfirmationBuilder {
    var items: [ConfirmationItemViewModel] = []
    let operativeData: NewFavouriteOperativeData
    let dependenciesResolver: DependenciesResolver
    
    init(operativeData: NewFavouriteOperativeData, dependenciesResolver: DependenciesResolver) {
        self.operativeData = operativeData
        self.dependenciesResolver = dependenciesResolver
    }
    
    func addAlias() {
        let name = self.operativeData.alias ?? ""
        let item = ConfirmationItemViewModel(
            title: localized("pt_cross_hint_saveFavoriteName"),
            value: name.capitalized
        )
        self.items.append(item)
    }
    
    func addBeneficiary() {
        let name = self.operativeData.beneficiaryName ?? ""
        let item = ConfirmationItemViewModel(
            title: localized("sendMoney_label_recipients"),
            value: name.capitalized,
            accessibilityIdentifier: "sendMoney_label_recipients"
        )
        self.items.append(item)
    }
    
    func addIban() {
        let name = self.operativeData.iban?.ibanPapel ?? ""
        let item = ConfirmationItemViewModel(
            title: localized("sendMoney_label_iban"),
            value: name,
            accessibilityIdentifier: "sendMoney_label_iban"
        )
        self.items.append(item)
    }
    
    func addCountryDestination() {
        let country = self.operativeData.country?.name ?? ""
        let currency = self.operativeData.currency?.name ?? ""
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
