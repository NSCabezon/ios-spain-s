//
//  BIllEmittersManualPaymentFieldView.swift
//  Bills
//
//  Created by José Carlos Estela Anguita on 26/05/2020.
//

import UI
import CoreFoundationLib
import UIKit

struct BillEmittersManualPaymentFieldRetrievableValue {
    enum Value {
        case amount(value: String)
        case any(viewModel: FieldViewModel?, value: String)
    }
    let value: Value
}

protocol FieldErrorActionable {
    var identifier: String { get }
    func showError(_ error: String?)
    func hideError()
}

protocol BillEmittersManualPaymentFieldRetrievable {
    var retrievedValue: BillEmittersManualPaymentFieldRetrievableValue { get }
}

class BillEmittersManualPaymentFieldView: XibView {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var tooltipButton: UIButton!
    @IBOutlet private weak var lisboaTextFieldView: LisboaTextFieldWithErrorView!
    public var textField: LisboaTextField {
        return lisboaTextFieldView.textField
    }
    private var viewModel: FieldViewModel?

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setup()
    }
    
    func setupWithViewModel(_ viewModel: FieldViewModel) {
        self.viewModel = viewModel
        let formatter = UIFormattedCustomTextField()
        formatter.setMaxLength(maxLength: viewModel.length)
        formatter.setAllowOnlyCharacters(.alphanumerics)
        self.textField.setEditingStyle(.writable(configuration: LisboaTextField.WritableTextField(type: .simple, formatter: formatter, disabledActions: [], keyboardReturnAction: nil, textfieldCustomizationBlock: self.setupTextField(_:))))
        self.titleLabel.text = viewModel.description.capitalized
        self.textField.accessibilityIdentifier = "areaInputText"
    }
    
    @IBAction func didTapOnTooltip(_ sender: UIButton) {
        let styledText: LocalizedStylableText = localized("receiptsAndTaxes_tooltip_numericCode", [
            StringPlaceholder(.value, self.viewModel?.description.capitalized ?? ""),
            StringPlaceholder(.number, "\(self.viewModel?.length ?? 0)")
        ])
        BubbleLabelView.startWith(associated: sender, text: styledText.text, position: .bottom)
    }
}

extension BillEmittersManualPaymentFieldView: BillEmittersManualPaymentFieldRetrievable {
    
    var retrievedValue: BillEmittersManualPaymentFieldRetrievableValue {
        return BillEmittersManualPaymentFieldRetrievableValue(
            value: .any(
                viewModel: self.viewModel,
                value: self.textField.text ?? ""
            )
        )
    }
}

private extension BillEmittersManualPaymentFieldView {

    func setupTextField(_ component: LisboaTextField.CustomizableComponents) {
        component.textField.autocorrectionType = .no
        component.textField.spellCheckingType = .no
        component.textField.addTarget(self, action: #selector(hideError), for: .editingChanged)
    }
    
    func setup() {
        self.tooltipButton.setImage(Assets.image(named: "icnInfoRedLight")?.withRenderingMode(.alwaysOriginal), for: .normal)
        self.tooltipButton.isAccessibilityElement = true
        self.titleLabel.textColor = UIColor.lisboaGray
        self.titleLabel.font = .santander(family: .text, type: .regular, size: 14)
    }
}

extension BillEmittersManualPaymentFieldView: FieldErrorActionable {
    var identifier: String {
        return self.viewModel?.identifier ?? ""
    }
    
    func showError(_ error: String?) {
        self.titleLabel.textColor = .bostonRed
        self.lisboaTextFieldView?.showError(error)
    }
    
    @objc func hideError() {
        self.titleLabel.textColor = .lisboaGray
        self.lisboaTextFieldView?.hideError()
    }
}
