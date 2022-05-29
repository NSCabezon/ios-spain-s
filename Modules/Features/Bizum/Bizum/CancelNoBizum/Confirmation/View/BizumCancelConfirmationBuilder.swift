import Operative
import CoreFoundationLib

enum BizumCancelItemViewModel {
    case confirmation(item: ConfirmationItemViewModel)
    case total(time: ConfirmationTotalOperationItemViewModel)
}

final class BizumCancelConfirmationBuilder {
    private let data: BizumCancelOperativeData
    private var items: [BizumCancelItemViewModel] = []
    private let bizumOperationEntity: BizumOperationEntity?
    
    required init(data: BizumCancelOperativeData) {
        self.data = data
        self.bizumOperationEntity = data.operationEntity.bizumOperationEntity
    }
    
    func build() -> [BizumCancelItemViewModel] {
        return self.items
    }
    
    func addAmountAndConcept() {
        guard let amount = self.bizumOperationEntity?.amount,
              let moneyDecorator = MoneyDecorator(AmountEntity(value: Decimal(amount)), font: .santander(family: .text, type: .bold, size: 32)).getFormatedAbsWith1M() else { return }
        let concept: String = self.bizumOperationEntity?.concept ?? localized("bizum_label_notConcept").text
        let item = ConfirmationItemViewModel(
            title: localized("confirmation_item_amount"),
            value: moneyDecorator,
            position: .first,
            info: NSAttributedString(string: concept),
            accessibilityIdentifier: AccessibilityOtherOperatives.lblConfirmationAmount.rawValue
        )
        self.items.append(.confirmation(item: item))
    }
    
    func addSendingDate() {
        let item = ConfirmationItemViewModel(
            title: localized("confirmation_item_shippingDate"),
            value: self.bizumOperationEntity?.date?.operativeDetailDate() ?? "",
            accessibilityIdentifier: AccessibilityOtherOperatives.lblConfirmationShippingDate.rawValue
        )
        self.items.append(.confirmation(item: item))
    }
    
    func addOriginAccount() {
        guard let originAccount = self.data.accountEntity else { return }
        let alias = originAccount.alias ?? ""
        let availableAmount = originAccount.currentBalanceAmount?.getStringValue() ?? ""
        var title: LocalizedStylableText = localized("confirmation_text_origin")
        let item = ConfirmationItemViewModel(
            title: title.camelCased(),
            value: BizumUtils.boldRegularAttributedString(bold: alias, regular: availableAmount),
            accessibilityIdentifier: AccessibilityOtherOperatives.lblConfirmationOrigin.rawValue
        )
        self.items.append(.confirmation(item: item))
    }
    
    func addTransferType() {
        let item = ConfirmationItemViewModel(
            title: localized("confirmation_label_sendType"),
            value: localized("confirmation_text_bizumNoCommissions"),
            accessibilityIdentifier: AccessibilityOtherOperatives.lblConfirmationSendType.rawValue)
        self.items.append(.confirmation(item: item))
    }
    
    func addContactPhone() {
        let phone = self.bizumOperationEntity?.receptorId?.tlfFormatted() ?? ""
        let phoneFormatted = BizumUtils.boldBulletAttributedString(phone)
        let item = ConfirmationItemViewModel(
            title: localized("confirmation_label_destination"),
            value: phoneFormatted,
            position: .last,
            accessibilityIdentifier: AccessibilityOtherOperatives.lblConfirmationDestination.rawValue)
        self.items.append(.confirmation(item: item))
    }
    
    func addTotal() {
        guard let amount = self.bizumOperationEntity?.amount else { return }
        let item = ConfirmationTotalOperationItemViewModel(amountEntity: AmountEntity(value: Decimal(amount)))
        self.items.append(.total(time: item))
    }
}
