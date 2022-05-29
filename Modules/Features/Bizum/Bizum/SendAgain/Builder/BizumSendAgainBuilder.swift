import UI
import CoreFoundationLib

enum BizumSendAgainViewModel {
    case title(_ item: TextWithAccessibility)
    case amount(_ items: ItemDetailAmountViewModel)
    case defaultItem(_ item: ItemDetailViewModel)
    case sendButton( _ item: String)
}

final class BizumSendAgainBuilder {
    private let configuration: BizumSendAgainConfiguration
    private(set) var items: [BizumSendAgainViewModel] = []

    init(configuration: BizumSendAgainConfiguration) {
        self.configuration = configuration
    }

    func build() -> [BizumSendAgainViewModel] {
        return items
    }

    @discardableResult
    func addTitle() -> Self {
        guard let title = getTitle() else { return self }
        self.items.append(.title(title))
        return self
    }

    @discardableResult
    func addItems() -> Self {
        switch configuration.type {
        case .request:
            return addRequestItems()
        case .send:
            return addSendItems()
        }
    }

    func addContact() -> Self {
        let title = TextWithAccessibility(text: "bizumDetail_label_destination", accessibility: AccessibilityBizumDetail.bizumLabelDestination)
        let value = getContactValue()
        let info = getContactInfo()
        let item = ItemDetailViewModel(title: title, value: value, info: info)
        self.items.append(.defaultItem(item))
        return self
    }

    @discardableResult
    func addContinueButton() -> Self {
        self.items.append(.sendButton("generic_button_send"))
        return self
    }
}

private extension BizumSendAgainBuilder {
    func getTitle() -> TextWithAccessibility? {
        switch configuration.type {
        case .request:
            return TextWithAccessibility(text: "bizum_label_requestAgain", accessibility: AccessibilityBizumSendAgain.titleRequestAgain)
        case .send:
            return TextWithAccessibility(text: "transfer_label_sendAgain", accessibility: AccessibilityBizumSendAgain.titleSendAgain)
        }
    }

    func addSendItems() -> Self {
        configuration.items.forEach { viewModel in
            switch viewModel {
            case .amount(let item):
                guard let amountValue = item.amount.value,
                      let moneyDecorator = MoneyDecorator(AmountEntity(value: abs(amountValue)),
                                                          font: .santander(family: .text, type: .bold, size: 18),
                                                          decimalFontSize: 18).formatAsMillions() else { return }
                item.setTitle(TextWithAccessibility(text: "confirmation_label_totalAmount", accessibility: AccessibilityBizumSendAgain.totalAmountTitle))
                item.setAmountStyle(moneyDecorator)
                item.setAmountAccessibility(AccessibilityBizumSendAgain.totalAmountValue)
                item.setInfoStyle(LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .italic, size: 14)))
                item.setInfoAccessibility(AccessibilityBizumSendAgain.totalAmountInfo)
                self.items.append(.amount(item))
            case .origin(let item):
                item.setValueAccessibility(AccessibilityBizumSendAgain.emitterValue)
                item.setInfoAccessibility(AccessibilityBizumSendAgain.emitterInfo)
                self.items.append(.defaultItem(item))
            case .transferType(let item):
                item.setValueAccessibility(AccessibilityBizumSendAgain.transferTypeValue)
                item.removeInfo()
                self.items.append(.defaultItem(item))
            default:
                break
            }
        }
        return self
    }

    func addRequestItems() -> Self {
        configuration.items.forEach { viewModel in
            switch viewModel {
            case .amount(let item):
                guard let moneyDecorator = MoneyDecorator(item.amount, font: .santander(family: .text, type: .bold, size: 18),
                                                          decimalFontSize: 18).formatAsMillions() else { return }
                item.setTitle(TextWithAccessibility(text: "confirmation_label_totalAmount", accessibility: AccessibilityBizumSendAgain.totalAmountTitle))
                item.setAmountStyle(moneyDecorator)
                item.setAmountAccessibility(AccessibilityBizumSendAgain.totalAmountValue)
                item.setInfoStyle(LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .italic, size: 14)))
                item.setInfoAccessibility(AccessibilityBizumSendAgain.totalAmountInfo)
                self.items.append(.amount(item))
            default:
                break
            }
        }
        return self
    }

    func getContactValue() -> TextWithAccessibility? {
        let value: TextWithAccessibility?
        if let receiverAlias = self.configuration.contact.alias, !receiverAlias.isEmpty {
            value = TextWithAccessibility(text: receiverAlias)
        } else {
            let phone = self.configuration.contact.phone.tlfFormatted()
            value = TextWithAccessibility(text: phone)
        }
        value?.setStyle(LocalizedStylableTextConfiguration(font: UIFont.santander(family: .text, type: .bold, size: 14)))
        value?.setAccessibility(AccessibilityBizumSendAgain.receiverValue)
        return value
    }

    func getContactInfo() -> TextWithAccessibility? {
        guard let receiverAlias = self.configuration.contact.alias, !receiverAlias.isEmpty else { return nil }
        let phone = self.configuration.contact.phone.tlfFormatted()
        let info = TextWithAccessibility(text: phone)
        info.setStyle(LocalizedStylableTextConfiguration(font: UIFont.santander(family: .text, type: .regular, size: 14)))
        info.setAccessibility(AccessibilityBizumSendAgain.receiverInfo)
        return info
    }
}
