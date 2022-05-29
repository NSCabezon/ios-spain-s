import Foundation
import CoreFoundationLib

final class BizumSimpleAmountViewModel {
    let amount: String
    let concept: String

    init(_ bizumSendMoney: BizumSendMoney?) {
        self.amount = bizumSendMoney?.amount.getFormattedValue() ?? ""
        self.concept = bizumSendMoney?.concept ?? ""
    }

    func updateView(view: BizumSimpleAmountViewProtocol) {
        view.setViewModel(self)
    }
}
