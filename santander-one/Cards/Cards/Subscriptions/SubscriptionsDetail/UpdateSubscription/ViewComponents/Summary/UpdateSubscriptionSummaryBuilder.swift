import Operative
import CoreFoundationLib

final class UpdateSubscriptionSummaryBuilder {
    private let operativeData: UpdateSubscriptionOperativeData
    private let dependenciesResolver: DependenciesResolver
    private var bodyItems: [OperativeSummaryStandardBodyItemViewModel] = []
    private var footerItems: [OperativeSummaryStandardFooterItemViewModel] = []
    private var bodyActionItems: [OperativeSummaryStandardBodyActionViewModel] = []

    init(operativeData: UpdateSubscriptionOperativeData, dependenciesResolver: DependenciesResolver) {
        self.operativeData = operativeData
        self.dependenciesResolver = dependenciesResolver
    }

    func addReceipt() {
        addAmount()
        addCard()
        addLastPayment()
    }

    func build() -> OperativeSummaryStandardViewModel? {
        guard let isActive = self.operativeData.isActive else {
            return nil
        }
        let descriptionKey: String = isActive ? "summary_label_disablePaymentsOk" : "summary_label_enabledPaymentsOk"
        let header = OperativeSummaryStandardHeaderViewModel(
            image: "icnCheckOval1",
            title: localized("summe_title_perfect"),
            description: localized(descriptionKey),
            extraInfo: nil
        )
        return OperativeSummaryStandardViewModel(
            header: header,
            bodyItems: self.bodyItems,
            bodyActionItems: self.bodyActionItems,
            footerItems: self.footerItems
        )
    }

    // MARK: Footer Items
    func addGoToMyCards(withAction action: @escaping () -> Void) {
        let viewModel = OperativeSummaryStandardFooterItemViewModel(
            imageKey: "icnCardMini",
            title: localized("generic_button_myCards"),
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

    func addGoToOpinator(withAction action: @escaping () -> Void) {
        let viewModel = OperativeSummaryStandardFooterItemViewModel(
            imageKey: "icnLike",
            title: localized("generic_button_improve"),
            action: action
        )
        self.footerItems.append(viewModel)
    }
}

private extension UpdateSubscriptionSummaryBuilder {
    // MARK: Body Items
    func addAmount() {
        guard let amount = self.operativeData.cardSubscriptionEntity.amount else {
            return
        }
        let moneyDecorator = MoneyDecorator(amount, font: .santander(family: .text, type: .bold, size: 32))
        let subTitle = moneyDecorator.getFormatedAbsWith1M() ?? NSAttributedString(string: amount.getStringValue())
        let info = self.operativeData.cardSubscriptionEntity.providerName
        let item = OperativeSummaryStandardBodyItemViewModel(
            title: localized("summary_item_amount"),
            subTitle: subTitle,
            info: info
        )
        self.bodyItems.append(item)
    }

    func addCard() {
        let subTitle = self.operativeData.cardEntity.getAliasAndInfo()
        let item = OperativeSummaryStandardBodyItemViewModel(
            title: localized("summary_item_card"),
            subTitle: subTitle
        )
        self.bodyItems.append(item)
    }

    func addLastPayment() {
        guard let lastPaymentDate = dateToString(date: self.operativeData.cardSubscriptionEntity.lastStateChangeDate, outputFormat: .d_MMM_yyyy) else {
            return
        }
        let item = OperativeSummaryStandardBodyItemViewModel(
            title: localized("summary_item_lastPayments"),
            subTitle: lastPaymentDate
        )
        self.bodyItems.append(item)
    }
}
