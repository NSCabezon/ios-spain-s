import Operative
import CoreFoundationLib

final class EasyPaySummaryBuilder {
    
    private let operativeData: EasyPayOperativeData
    private var bodyItems: [OperativeSummaryStandardBodyItemViewModel] = []
    private var footerItems: [OperativeSummaryStandardFooterItemViewModel] = []
    private var bodyActionItems: [OperativeSummaryStandardBodyActionViewModel] = []
    private let dependenciesResolver: DependenciesResolver
    
    init(operativeData: EasyPayOperativeData, dependenciesResolver: DependenciesResolver) {
        self.operativeData = operativeData
        self.dependenciesResolver = dependenciesResolver
    }

    // MARK: Content
    func addAmountAndConcept() {
        guard let amount = operativeData.easyPayContractTransaction?.amount,
              let moneyDecorator = MoneyDecorator(amount,
                                                  font: .santander(family: .text, type: .bold, size: 32),
                                                  decimalFontSize: 18.0)
                .getFormatedAbsWith1M()
        else { return }
        let concept: String = operativeData.productSelected?.cardTransactionEntity.description?.camelCasedString ?? ""
        let item = OperativeSummaryStandardBodyItemViewModel(title: localized("summary_item_postponeAmount"),
                                                             subTitle: moneyDecorator,
                                                             info: concept,
                                                             accessibilityIdentifier: "summary_item_postponeAmount")
        self.bodyItems.append(item)
    }
    
    func addNumberOfFees() {
        let subTitle = String(operativeData.easyPayAmortization?.amortizations.count ?? 0)
        let item = OperativeSummaryStandardBodyItemViewModel(title: localized("summary_item_fee"),
                                                             subTitle: subTitle)
        self.bodyItems.append(item)
    }
    
    func addFeeValue() {
        guard let totalAmount = operativeData.easyPayContractTransaction?.amount?.value,
              let currency = operativeData.easyPayContractTransaction?.amount?.dto.currency,
              let numberOfFees = operativeData.easyPayAmortization?.amortizations.count,
              numberOfFees > 0
        else { return }
        let feeValue = abs(totalAmount / Decimal(numberOfFees))
        
        let fee = AmountEntity(value: feeValue,
                               currency: currency.currencyType)
        guard let moneyDecorator = MoneyDecorator(fee,
                                                  font: .santander(family: .text, type: .bold, size: 14.0),
                                                  decimalFontSize: 14.0)
                .getFormatedCurrency()
        else { return }
        let item = OperativeSummaryStandardBodyItemViewModel(title: localized("summary_item_feeAmount"),
                                                             subTitle: moneyDecorator,
                                                             accessibilityIdentifier: "summary_item_feeAmount")
        self.bodyItems.append(item)
    }
    
    func addStartDate() {
        guard
            let date = operativeData.easyPayAmortization?.amortizations.first?.nextAmortizationDate
        else { return }
        let item = OperativeSummaryStandardBodyItemViewModel(title: localized("summary_item_startDate"),
                                                             subTitle: dateToString(date: date, outputFormat: .dd_MMM_yyyy) ?? "",
                                                             accessibilityIdentifier: "summary_item_endDate")
        self.bodyItems.append(item)
    }
    
    func addEndDate() {
        guard
            let date = operativeData.easyPayAmortization?.amortizations.last?.nextAmortizationDate
        else { return }
        let item = OperativeSummaryStandardBodyItemViewModel(title: localized("summary_item_endDate"),
                                                             subTitle: dateToString(date: date, outputFormat: .dd_MMM_yyyy) ?? "",
                                                             accessibilityIdentifier: "summary_item_endDate")
        self.bodyItems.append(item)
    }
    
    func addShareAction(withAction action: @escaping () -> Void) {
        let item = OperativeSummaryStandardBodyActionViewModel(image: "icnShareBostonRedLight",
                                                               title: localized("generic_button_share"),
                                                               action: action)
        bodyActionItems.append(item)
    }
    
    func addMoreBuysAction(withAction action: @escaping () -> Void) {
        let item = OperativeSummaryStandardBodyActionViewModel(image: "icnFractionablePurchases",
                                                               title: localized("cardsOption_button_moreFractionalPurchases"),
                                                               action: action)
        bodyActionItems.append(item)
    }
    
    // MARK: Footer
    func addGoTofinancing(withAction action: @escaping () -> Void) {
        let viewModel = OperativeSummaryStandardFooterItemViewModel(
            imageKey: "icnPig",
            title: localized("generic_button_goFinancing"),
            action: action
        )
        self.footerItems.append(viewModel)
    }
    
    func addHelpUsToImprove(withAction action: @escaping () -> Void) {
        let viewModel = OperativeSummaryStandardFooterItemViewModel(
            imageKey: "icnLike",
            title: localized("generic_button_improve"),
            action: action
        )
        self.footerItems.append(viewModel)
    }
    
    func addGoToGlobalPosition(withAction action: @escaping () -> Void) {
        let viewModel = OperativeSummaryStandardFooterItemViewModel(
            imageKey: "icnHome",
            title: localized("generic_button_globalPosition"),
            action: action
        )
        self.footerItems.append(viewModel)
    }
  
    func build() -> OperativeSummaryStandardViewModel {
        return OperativeSummaryStandardViewModel(
            header: OperativeSummaryStandardHeaderViewModel(image: "icnCheckOval1",
                                                            title: localized("summe_title_perfect"),
                                                            description: localized("summary_item_fractionalPurchase"),
                                                            extraInfo: nil),
            bodyItems: self.bodyItems,
            bodyActionItems: self.bodyActionItems,
            footerItems: self.footerItems
        )
    }
}
