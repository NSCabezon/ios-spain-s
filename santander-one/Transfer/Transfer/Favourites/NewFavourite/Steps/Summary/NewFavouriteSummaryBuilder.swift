import Operative
import CoreFoundationLib

final class NewFavouriteSummaryBuilder {
    let operativeData: NewFavouriteOperativeData
    var bodyItems: [OperativeSummaryStandardBodyItemViewModel] = []
    var footerItems: [OperativeSummaryStandardFooterItemViewModel] = []
    
    init(operativeData: NewFavouriteOperativeData) {
        self.operativeData = operativeData
    }
    
    func addAlias() {
        guard let alias = self.operativeData.alias else { return }
        let item = OperativeSummaryStandardBodyItemViewModel(
            title: localized("pt_cross_hint_saveFavoriteName"),
            subTitle: alias
        )
        self.bodyItems.append(item)
    }
    
    func addBeneficiary() {
        guard let beneficiaryName = self.operativeData.beneficiaryName,
              let iban = self.operativeData.iban?.ibanPapel
        else { return }
        let item = OperativeSummaryStandardBodyItemViewModel(
            title: localized("confirmation_item_recipient"),
            subTitle: beneficiaryName,
            info: iban
        )
        self.bodyItems.append(item)
    }
    
    func addCountry() {
        guard let country = self.operativeData.country?.name,
              let currency = self.operativeData.country?.name
              else { return }
        let item = OperativeSummaryStandardBodyItemViewModel(
            title: localized("summary_item_destinationCountry"),
            subTitle: country + " - " + currency
        )
        self.bodyItems.append(item)
    }
    
    //: MARK - Footer
    func addNewSend(withAction action: @escaping () -> Void) {
        let viewModel = OperativeSummaryStandardFooterItemViewModel(
            imageKey: "icnSendMoney",
            title: localized("pt_cross_footerButton_sendMoney"),
            action: action
        )
        self.footerItems.append(viewModel)
    }
    
    func addGoPG(withAction action: @escaping () -> Void) {
        let viewModel = OperativeSummaryStandardFooterItemViewModel(
            imageKey: "icnHome",
            title: localized("pt_cross_footerButton_globalPosition"),
            action: action
        )
        self.footerItems.append(viewModel)
    }
    
    func addHelpImprove(withAction action: @escaping () -> Void) {
        let viewModel = OperativeSummaryStandardFooterItemViewModel(
            imageKey: "icnLike",
            title: localized("pt_cross_footerButton_helpImprove"),
            action: action
        )
        self.footerItems.append(viewModel)
    }
    
    func build() -> OperativeSummaryStandardViewModel {
        return OperativeSummaryStandardViewModel(
            header: OperativeSummaryStandardHeaderViewModel(
                image: "icnCheckOval1",
                title: localized("summe_title_perfect"),
                description: localized("summary_title_newFavoriteRecipients")),
            bodyItems: self.bodyItems,
            bodyActionItems: [],
            footerItems: self.footerItems
        )
    }
}
