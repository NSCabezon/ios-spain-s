import CoreFoundationLib
import Operative

final class DeleteFavouriteConfirmationBuilder {
    var items: [ConfirmationItemViewModel] = []
    let operativeData: DeleteFavouriteOperativeData
    let dependenciesResolver: DependenciesResolver
    
    init(operativeData: DeleteFavouriteOperativeData, dependenciesResolver: DependenciesResolver) {
        self.operativeData = operativeData
        self.dependenciesResolver = dependenciesResolver
    }
    
    func addAlias() {
        let name = self.operativeData.favouriteType?.alias ?? ""
        let item = ConfirmationItemViewModel(
            title: localized("confirmation_item_alias"),
            value: name.capitalized
        )
        self.items.append(item)
    }
    
    func addBeneficiary() {
        let name = self.operativeData.favouriteType?.name ?? ""
        let item = ConfirmationItemViewModel(
            title: localized("confirmation_item_holder"),
            value: name.capitalized
        )
        self.items.append(item)
    }
    
    func addIban() {
        let name = self.operativeData.favouriteType?.account ?? ""
        let item = ConfirmationItemViewModel(
            title: localized("sendMoney_label_iban"),
            value: name
        )
        self.items.append(item)
    }
    
    func addCountryDestination() {
        let countryCode = self.operativeData.favouriteType?.countryCode ?? ""
        let country = self.operativeData.sepaList?.countryFor(countryCode) ?? ""
        let currencyCode = self.operativeData.favouriteType?.favorite.currencyName ?? ""
        let currency = self.operativeData.sepaList?.currencyFor(currencyCode) ?? ""
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
