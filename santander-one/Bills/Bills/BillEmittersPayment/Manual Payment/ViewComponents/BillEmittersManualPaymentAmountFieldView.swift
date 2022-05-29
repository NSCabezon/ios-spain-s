//
//  BIllEmittersManualPaymentAmountFieldView.swift
//  Bills
//
//  Created by José Carlos Estela Anguita on 26/05/2020.
//

import UI
import CoreFoundationLib

class BillEmittersManualPaymentAmountFieldView: XibView {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet weak var lisboaTextFieldView: LisboaTextFieldWithErrorView!
    public var textField: LisboaTextField { return lisboaTextFieldView.textField }
    private let amountFormatter = UIAmountTextFieldFormatter()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setup()
    }
}

extension BillEmittersManualPaymentAmountFieldView: BillEmittersManualPaymentFieldRetrievable {
    
    var retrievedValue: BillEmittersManualPaymentFieldRetrievableValue {
        return BillEmittersManualPaymentFieldRetrievableValue(
            value: .amount(value: textField.text ?? "")
        )
    }
}

private extension BillEmittersManualPaymentAmountFieldView {
    func setup() {
        self.titleLabel.text = localized("receiptsAndTaxes_label_amount")
        self.titleLabel.textColor = UIColor.lisboaGray
        self.titleLabel.font = .santander(family: .text, type: .regular, size: 14)
        self.titleLabel.accessibilityIdentifier = "receiptsAndTaxes_label_amount"
        self.textField.accessibilityIdentifier = "areaInputText"
        self.textField.setEditingStyle(.writable(configuration: LisboaTextField.WritableTextField(type: .simple, formatter: self.amountFormatter, disabledActions: [], keyboardReturnAction: nil, textfieldCustomizationBlock: self.setupTextField(_:))))
        let icnCurrency = NumberFormattingHandler.shared.getDefaultCurrencyTextFieldIcn()
        self.textField.setRightAccessory(.image(icnCurrency, action: { self.textField.becomeFirstResponder() }))
        self.textField.keyboardToolbar.doneBarButton.setTarget(self, action: #selector(self.dismissKeyboard))
    }
    
    @objc func dismissKeyboard() {
        self.textField.endEditing(true)
    }
    
    func setupTextField(_ component: LisboaTextField.CustomizableComponents) {
        component.textField.autocorrectionType = .no
        component.textField.spellCheckingType = .no
        component.textField.keyboardType = .decimalPad
        component.textField.addTarget(self, action: #selector(hideError), for: .editingChanged)
    }
}

extension BillEmittersManualPaymentAmountFieldView: FieldErrorActionable {
    var identifier: String {
        return "AMOUNT"
    }
    
    func showError(_ error: String?) {
        self.titleLabel.textColor = .bostonRed
        self.lisboaTextFieldView.showError(error ?? "")
    }

    @objc func hideError() {
        self.titleLabel.textColor = .lisboaGray
        self.lisboaTextFieldView.hideError()
    }
}
