import Foundation
import CoreFoundationLib

protocol BizumMultipleAmountViewProtocol: class {
    var amountWasUpdated: (String?) -> Void { get set }
    func showTotalAmount(_ amount: Decimal)
    func updateAllDestinationsAmount(_ amount: NSAttributedString)
    func show(amount: Decimal, contacts: [BizumContactDetailModel])
    func showConcept(_ concept: String)
    func preloadAmountPerDestination(_ amount: String)
    func showHintAmountValue(_ value: String)
}

class BizumMultipleAmountViewModel {
    private var amountAtributte: NSAttributedString {
        let amountAtributte = MoneyDecorator(AmountEntity(value: amount),
                                             font: UIFont.santander(family: .text,
                                                                    type: .regular,
                                                                    size: 17.0), decimalFontSize: 17.0).formatAsMillions()
        return amountAtributte ?? NSAttributedString()
    }
    let concept: String
    var amount: Decimal = 0
    let contacts: [BizumContactDetailModel]
    let bizumOperativeType: BizumOperativeType
    weak var view: BizumMultipleAmountViewProtocol?
    weak var updatableSendingMoneyDelegate: BizumUpdatableSendingMoneyDelegate?

    init(bizumOperativeType: BizumOperativeType, contacts: [BizumContactDetailModel], amount: Decimal?, concept: String?, view: BizumMultipleAmountViewProtocol? = nil) {
        self.contacts = contacts
        self.bizumOperativeType = bizumOperativeType
        self.amount = amount ?? 0
        self.concept = concept ?? ""
        self.view = view
    }

    func updateView(view: BizumMultipleAmountViewProtocol) {
        self.view = view
        self.showHintContactValue()
        view.show(amount: amount, contacts: contacts)
        if self.amount > 0 {
            view.preloadAmountPerDestination(amount.getSmartFormattedValue())
            self.calculateTotalAmount()
        }
        view.showConcept(self.concept)
        view.amountWasUpdated = { amount in
            self.amount = amount?.stringToDecimal ?? 0
            self.updatableSendingMoneyDelegate?.updateSendingAmount(self.amount)
            self.calculateTotalAmount()
        }
    }

    func calculateTotalAmount() {
        let totalContacts = NSDecimalNumber(value: contacts.count)
        let totalAmount = (self.amount as NSDecimalNumber).multiplying(by: totalContacts)
        self.view?.showTotalAmount(totalAmount.decimalValue)
        self.view?.updateAllDestinationsAmount(amountAtributte)
    }
}

private extension BizumMultipleAmountViewModel {
    func showHintContactValue() {
        let value: String
        switch self.bizumOperativeType {
        case .sendMoney:
            value = "bizum_tooltip_sameAmount"
        case .requestMoney:
            value = "bizum_tooltip_sameAmountRequest"
        case .donation:
            return
        }
        self.view?.showHintAmountValue(value)
    }
}
