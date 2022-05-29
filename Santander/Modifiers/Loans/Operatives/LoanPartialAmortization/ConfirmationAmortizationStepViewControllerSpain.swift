import CoreFoundationLib
import Foundation
import Loans
import Operative
import UI

protocol ConfirmationAmortizationStepViewSpainProtocol: ConfirmationAmortizationStepViewModifierProtocol {
    func addConditionsCheckboxView(isSelected: Bool)
    func selectCheckBox()
    func enableConfirmButtonSpain()
    func disableConfirmButtonSpain()
}

class ConfirmationAmortizationStepViewControllerSpain: ConfirmationAmortizationStepViewController {}

extension ConfirmationAmortizationStepViewControllerSpain: ConfirmationAmortizationStepViewSpainProtocol {
    func addConditionsCheckboxView(isSelected: Bool) {
        let conditionsCheckView = CheckTextLinkView()
        conditionsCheckView.setup(title: LocalizedStylableText(text: "confirmation_item_conditions", styles: []), accessibilityId: "confirmation_item_conditions", isSelected: isSelected, isDeselectingAllowed: false, delegate: self, hasShadow: true)
        let idx = self.scrollableStackView.getArrangedSubviews().count - 1
        self.scrollableStackView.stackView.insertArrangedSubview(conditionsCheckView, at: idx)
    }

    func selectCheckBox() {
        if let conditionsCheckView = self.scrollableStackView.stackView.arrangedSubviews.first(where: { $0 is CheckTextLinkView }) as? CheckTextLinkView {
            conditionsCheckView.setCheckBoxEnabled(true)
        }
    }

    func enableConfirmButtonSpain() {
        self.enableConfirmButton()
    }

    func disableConfirmButtonSpain() {
        self.disableConfirmButton()
    }
}

extension ConfirmationAmortizationStepViewControllerSpain: CheckTextLinkViewDelegate {
    func didTouchCheckBox(isSelected: Bool) {
        let presenterSpain = self.presenter as? ConfirmationAmortizationStepPresenterSpainProtocol
        presenterSpain?.didTouchCheckBox(isSelected: isSelected)
    }

    func didTouchLink() {
        let presenterSpain = self.presenter as? ConfirmationAmortizationStepPresenterSpainProtocol
        presenterSpain?.didTouchLink()
    }
}
