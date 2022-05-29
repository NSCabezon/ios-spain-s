import Operative
import CoreFoundationLib

final class DeleteFavouriteSummaryBuilder {
    let operativeData: DeleteFavouriteOperativeData
    var bodyItems: [OperativeSummaryStandardBodyItemViewModel] = []
    var footerItems: [OperativeSummaryStandardFooterItemViewModel] = []
    
    init(operativeData: DeleteFavouriteOperativeData) {
        self.operativeData = operativeData
    }
    
    func addAlias() {
        let name = self.operativeData.favouriteType?.alias ?? ""
        let item = OperativeSummaryStandardBodyItemViewModel(
            title: localized("summary_item_alias"),
            subTitle: name.capitalized
        )
        self.bodyItems.append(item)
    }
    
    func addBeneficiary() {
        guard let beneficiaryName = self.operativeData.favouriteType?.name,
              let iban = self.operativeData.favouriteType?.account
        else { return }
        let item = OperativeSummaryStandardBodyItemViewModel(
            title: localized("summary_item_recipient"),
            subTitle: beneficiaryName,
            info: iban
        )
        self.bodyItems.append(item)
    }
    
    func addCountry() {
        let countryCode = self.operativeData.favouriteType?.countryCode ?? ""
        let country = self.operativeData.sepaList?.countryFor(countryCode) ?? ""
        let currencyCode = self.operativeData.favouriteType?.favorite.currencyName ?? ""
        let currency = self.operativeData.sepaList?.currencyFor(currencyCode) ?? ""
        let name = country + " - " + currency
        let item = OperativeSummaryStandardBodyItemViewModel(
            title: localized("summary_item_destinationCountry"),
            subTitle: name
        )
        self.bodyItems.append(item)
    }
    
    //: MARK - Footer
    func addNewSend(withAction action: @escaping () -> Void) {
        let viewModel = OperativeSummaryStandardFooterItemViewModel(
            imageKey: "icnSendMoney",
            title: localized("generic_button_anotherSendMoney"),
            action: action
        )
        self.footerItems.append(viewModel)
    }
    
    func addGoPG(withAction action: @escaping () -> Void) {
        let viewModel = OperativeSummaryStandardFooterItemViewModel(
            imageKey: "icnHome",
            title: localized("generic_button_globalPosition"),
            action: action
        )
        self.footerItems.append(viewModel)
    }
    
    func addHelpImprove(withAction action: @escaping () -> Void) {
        let viewModel = OperativeSummaryStandardFooterItemViewModel(
            imageKey: "icnLike",
            title: localized("generic_button_improve"),
            action: action
        )
        self.footerItems.append(viewModel)
    }
    
    func build() -> OperativeSummaryStandardViewModel {
        return OperativeSummaryStandardViewModel(
            header: OperativeSummaryStandardHeaderViewModel(
                image: "icnCheckOval1",
                title: localized("summe_title_perfect"),
                description: localized("summary_title_deleteFavoriteRecipients")),
            bodyItems: self.bodyItems,
            bodyActionItems: [],
            footerItems: self.footerItems
        )
    }
}
