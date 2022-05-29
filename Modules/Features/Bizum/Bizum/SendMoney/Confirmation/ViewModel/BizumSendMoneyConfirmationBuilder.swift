import CoreFoundationLib
import Operative
import UI
import ESUI

enum BizumConfirmationItemViewModel {
    case confirmation(item: ConfirmationItemViewModel)
    case multimedia(item: [ImageLabelViewModel])
    case contacts(item: ConfirmationContainerViewModel)
    case total(time: ConfirmationTotalOperationItemViewModel)
}

final class BizumSendMoneyConfirmationBuilder {
    private let data: BizumSendMoneyOperativeData
    private var items: [BizumConfirmationItemViewModel] = []
    let dependenciesResolver: DependenciesResolver
    
    required init(data: BizumSendMoneyOperativeData, dependenciesResolver: DependenciesResolver) {
        self.data = data
        self.dependenciesResolver = dependenciesResolver
    }
    
    func build() -> [BizumConfirmationItemViewModel] {
        return self.items
    }
    
    func addAmountAndConcept(action: @escaping () -> Void) {
        guard let amount = self.data.bizumSendMoney?.totalAmount,
            let moneyDecorator = MoneyDecorator(amount, font: .santander(family: .text, type: .bold, size: 32)).getFormatedAbsWith1M() else { return }
        let item = ConfirmationItemViewModel(
            title: localized("confirmation_label_totalAmount"),
            value: moneyDecorator,
            position: .first,
            info: NSAttributedString(string: self.getOperationConcept()),
            action: ConfirmationItemAction(title: localized("generic_edit_link"), action: action),
            accessibilityIdentifier: AccessibilityOtherOperatives.lblConfirmationAmount.rawValue
        )
        self.items.append(.confirmation(item: item))
    }

    func addOriginAccount(action: @escaping () -> Void) {
        guard let originAccount = self.data.accountEntity else { return }
        let alias = originAccount.alias ?? ""
        let availableAmount = originAccount.currentBalanceAmount?.getStringValue() ?? ""
        var title: LocalizedStylableText = localized("confirmation_text_origin")
        let item = ConfirmationItemViewModel(
            title: title.camelCased(),
            value: BizumUtils.boldRegularAttributedString(bold: alias, regular: availableAmount),
            action: ConfirmationItemAction(title: localized("generic_edit_link"), action: action),
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
    
    func addMedia() {
        var viewModels: [ImageLabelViewModel] = []
        if let image = self.data.multimediaData?.image {
            let item = ImageLabelViewModel(imageSize: CGSize(width: 24.0, height: 24.0), image: UIImage(data: image), text: localized("toolbar_title_attachedImage"))
            viewModels.append(item)
        }
        if let note = self.data.multimediaData?.note {
            let item = ImageLabelViewModel(imageSize: CGSize(width: 32.0, height: 32.0), image: ESAssets.image(named: "icnNotes"), text: note)
            viewModels.append(item)
        }
        self.items.append(.multimedia(item: viewModels))
    }
    
    func addContacts(action: @escaping () -> Void) {
        let item = ConfirmationContainerViewModel(title: localized("confirmation_label_destination"), position: .last, action: ConfirmationContainerAction(title: localized("generic_edit_link"), action: action), views: [])
        self.items.append(.contacts(item: item))
    }
    
    func addTotal() {
        guard let amount = self.data.bizumSendMoney?.totalAmount else { return }
        let item = ConfirmationTotalOperationItemViewModel(amountEntity: amount)
        self.items.append(.total(time: item))
    }
}

private extension BizumSendMoneyConfirmationBuilder {
    func getOperationConcept() -> String {
       guard let concept = self.data.bizumSendMoney?.concept, !concept.isEmpty else {
            return localized("bizum_label_notConcept")
       }
       return concept
    }
}
