//
//  EditFavouriteSummaryBuilder.swift
//  Transfer
//
//  Created by Jose Enrique Montero Prieto on 12/08/2021.
//

import Operative
import CoreFoundationLib

final class EditFavouriteSummaryBuilder {
    let operativeData: EditFavouriteOperativeData
    var bodyItems: [OperativeSummaryStandardBodyItemViewModel] = []
    var footerItems: [OperativeSummaryStandardFooterItemViewModel] = []
    
    init(operativeData: EditFavouriteOperativeData) {
        self.operativeData = operativeData
    }
    
    func addAlias() {
        guard let alias = self.operativeData.selectedFavourite?.payeeDisplayName else { return }
        let item = OperativeSummaryStandardBodyItemViewModel(
            title: localized("pt_cross_hint_saveFavoriteName"),
            subTitle: alias
        )
        self.bodyItems.append(item)
    }
    
    func addBeneficiary() {
        guard let beneficiaryName = self.operativeData.newBeneficiaryName,
              let iban = self.operativeData.newDestinationAccount?.ibanPapel
        else { return }
        let item = OperativeSummaryStandardBodyItemViewModel(
            title: localized("confirmation_item_recipient"),
            subTitle: beneficiaryName,
            info: iban
        )
        self.bodyItems.append(item)
    }
    
    func addCountry() {
        guard let country = self.operativeData.currentCountry?.name,
              let currency = self.operativeData.currentCurrency?.name
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
                description: localized("summary_titie_favoriteRecipientsEdited")),
            bodyItems: self.bodyItems,
            bodyActionItems: [],
            footerItems: self.footerItems
        )
    }
}
