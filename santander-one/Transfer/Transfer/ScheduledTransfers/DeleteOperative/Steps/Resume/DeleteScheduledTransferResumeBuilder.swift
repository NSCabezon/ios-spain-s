//
//  DeleteScheduledTransferResumeBuilder.swift
//  Transfer
//
//  Created by Boris Chirino Fernandez on 21/7/21.
//

import Operative
import CoreFoundationLib

final class DeleteScheduledTransferResumeBuilder {
    let operativeData: DeleteScheduledTransferOperativeData
    private var bodyItems: [OperativeSummaryStandardBodyItemViewModel] = []
    private var bodyActionItems: [OperativeSummaryStandardBodyActionViewModel] = []
    private var footerItems: [OperativeSummaryStandardFooterItemViewModel] = []
    private var indefiniteYearLimit: Int {
        return 2100
    }
    
    init(operativeData: DeleteScheduledTransferOperativeData) {
        self.operativeData = operativeData
    }
    
    func addAmount() {
        guard let amountEntity = self.operativeData.order?.transferEntity?.amount ?? self.operativeData.detail?.transferAmount else {
            return
        }
        let font: UIFont = UIFont.santander(family: .text, type: .bold, size: 32.0)
        let formattedAmount = MoneyDecorator(amountEntity, font: font, decimalFontSize: 18.0)
        guard let formatedCurrency = formattedAmount.getFormatedCurrency() else { return }
        let item = OperativeSummaryStandardBodyItemViewModel(
            title: localized("summary_item_amount"),
            subTitle: formatedCurrency
        )
        self.bodyItems.append(item)
    }
    
    func addConcept() {
        guard let order = self.operativeData.order else { return }
        let noConceptKey = (order.isPeriodic) ? "onePay_label_genericPeriodic" : "onePay_label_genericProgrammed"
        let transferConcept = self.operativeData.order?.concept ?? localized(noConceptKey)
        let item = OperativeSummaryStandardBodyItemViewModel(
            title: localized("summary_item_concept"),
            subTitle: transferConcept.camelCasedString
        )
        self.bodyItems.append(item)
    }
    
    func addOriginAccount() {
        guard let accountAlias = operativeData.originAccountAlias else { return }
        let item = OperativeSummaryStandardBodyItemViewModel(
            title: localized("summary_item_originAccount"),
            subTitle: accountAlias
        )
        self.bodyItems.append(item)
    }
    
    func addOrderType() {
        guard let order = operativeData.order else { return }
        let item = OperativeSummaryStandardBodyItemViewModel(
            title: localized("summary_item_sendType"),
            subTitle: order.isPeriodic ? localized("summary_label_periodic") : localized("summary_label_programmed")
        )
        self.bodyItems.append(item)
    }
    
    func addBeneficiary() {
        guard let beneficiaryIban = self.operativeData.detail?.beneficiary,
              let beneficiaryName = self.operativeData.detail?.beneficiaryName else { return }
        let item = OperativeSummaryStandardBodyItemViewModel(
            title: localized("summary_label_destination"),
            subTitle: beneficiaryName.camelCasedString,
            info: beneficiaryIban.ibanPapel,
            titleImageURLString: self.operativeData.bankIconURL
        )
        self.bodyItems.append(item)
    }
    
    func addDestinationCountry() {
        guard let sepaList = self.operativeData.sepaInfoList,
              let destinationCountryCode = self.operativeData.detail?.beneficiary?.countryCode,
              let currency = self.operativeData.order?.currency else { return }
        
        let countryName = sepaList.countryFor(destinationCountryCode) ?? ""
        let currencyName = sepaList.currencyFor(currency) ?? ""
        let item = OperativeSummaryStandardBodyItemViewModel(
            title: localized("summary_item_destinationCountry"),
            subTitle: "\(countryName) - \(currencyName)",
            info: ""
        )
        self.bodyItems.append(item)
    }
    
    func addPeridiocity() {
        let periodicity = operativeData.order?.periodicityString ?? "summary_label_timely"
        let fromDate = operativeData.order?.emmitedDate
        let toDate = operativeData.detail?.endDate
        let item = OperativeSummaryStandardBodyItemViewModel(
            title: localized("summary_item_periodicity"),
            subTitle: localized(periodicity),
            info: self.periodicDateInterval(fromDate, toDate: toDate)
        )
        self.bodyItems.append(item)
    }
    
    func addEmissionDate() {
        guard let emissionDate = operativeData.order?.emmitedDate,
              let formattedDate = dateToStringFromCurrentLocale(date: emissionDate,
                                                                outputFormat: .dd_MMM_yyyy)
        else { return }
        let item = OperativeSummaryStandardBodyItemViewModel(
            title: localized("summary_item_issuerDate"),
            subTitle: formattedDate,
            info: ""
        )
        self.bodyItems.append(item)
    }
    
    func addShareAction(withAction action: @escaping () -> Void) {
        let item = OperativeSummaryStandardBodyActionViewModel(image: "icnShareBostonRedLight",
                                                               title: localized("generic_button_share"),
                                                               action: action)
        self.bodyActionItems.append(item)
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
        let isPeriodic = operativeData.order?.isPeriodic ?? false
        let description: String = isPeriodic ? localized("summary_title_removedPeriodicOnePay") : localized("summary_title_cancelOnePay")
        return OperativeSummaryStandardViewModel(
            header: OperativeSummaryStandardHeaderViewModel(
                image: "icnCheckOval1",
                title: localized("summe_title_perfect"),
                description: description),
            bodyItems: self.bodyItems,
            bodyActionItems: self.bodyActionItems,
            footerItems: self.footerItems
        )
    }
}

private extension DeleteScheduledTransferResumeBuilder {
    func periodicDateInterval(_ fromDate: Date?, toDate: Date?) -> String? {
        guard let order = operativeData.order, order.isPeriodic else {
            return nil
        }
        let fromDate = dateToString(date: fromDate,
                                    outputFormat: .dd_MMM_yyyy)
        var endDateLiteral: String = localized("detailsOnePay_label_indefinite")
        if let endDate = toDate, endDate.year < indefiniteYearLimit {
            endDateLiteral = dateToString(date: endDate, outputFormat: .dd_MMM_yyyy) ?? ""
        }
        return  String("\((fromDate ?? "")) - \(endDateLiteral)")
    }
}
