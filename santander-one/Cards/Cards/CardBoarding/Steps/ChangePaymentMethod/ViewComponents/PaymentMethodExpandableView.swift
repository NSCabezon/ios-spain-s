//
//  PaymentMethodExpandableView.swift
//  Cards
//
//  Created by Carlos Monfort Gómez on 07/10/2020.
//

import Foundation
import CoreFoundationLib
import UI

protocol PaymentMethodExpandableViewDelegate: AnyObject {
    func didSelectPaymentMethodExpandable(_ paymentMethod: PaymentMethodCategory)
}

class PaymentMethodExpandableView: XibView {
    @IBOutlet private weak var selectionBtn: UIButton!
    @IBOutlet private weak var paymentMethodView: UIView!
    @IBOutlet private weak var expandableView: UIView!
    @IBOutlet private weak var stackView: UIStackView!
    @IBOutlet private weak var expandableButton: UIButton!
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var expandableDescriptionLabel: UILabel!
    @IBOutlet weak var lisboaTexFieldView: LisboaTextField!
    @IBOutlet weak var minimumFeeLabel: UILabel!
    weak var delegate: PaymentMethodExpandableViewDelegate?
    private var viewModel: PaymentMethodExpandableViewModel?
    private weak var textField: UITextField?
    private weak var placeholderLabel: UILabel?
    private var paymentMethod: PaymentMethodCategory?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setAppearance()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setAppearance()
    }
    
    @IBAction private func expandableButtonPressed(_ sender: Any) {
        guard let viewModel = self.viewModel else { return }
        let amount = AmountEntity(value: viewModel.amountValues[self.getPickerValue() ?? 0])
        self.updatePaymentMethod(amount)
    }
    
    func setViewModel(_ viewModel: PaymentMethodExpandableViewModel?) {
        guard let newViewModel = viewModel else { return }
        self.viewModel = newViewModel
        self.paymentMethod = newViewModel.paymentMethod
        self.setLabelsText(from: newViewModel)
        self.setTextField(from: newViewModel)
        self.setViewState(newViewModel.viewState)
        self.setAccessibilityIdentifiers(from: newViewModel)
    }
    
    func setViewState(_ viewState: PaymentMethodViewState) {
        self.setViewStyle(viewState)
    }
}

private extension PaymentMethodExpandableView {
    func setAppearance() {
        self.setSubviewsAppearance()
        self.setLabelsStyle()
        self.setTextFieldEditingStyle()
    }
    
    func setSubviewsAppearance() {
        self.containerView?.drawRoundedAndShadowedNew(radius: 6, borderColor: .mediumSkyGray, widthOffSet: 1, heightOffSet: 2)
        self.containerView.backgroundColor = .white
        self.view?.backgroundColor = .clear
        self.expandableView.backgroundColor = .clear
        self.expandableView.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 6.0)
    }
    
    func setLabelsStyle() {
        self.titleLabel.font = .santander(family: .text, type: .bold, size: 20)
        self.expandableDescriptionLabel.font = .santander(family: .text, type: .light, size: 16)
        self.expandableDescriptionLabel.textColor = .lisboaGray
        self.minimumFeeLabel.font = .santander(family: .text, type: .regular, size: 16)
        self.minimumFeeLabel.textColor = .lisboaGray
    }
    
    func setAccessibilityIdentifiers(from viewModel: PaymentMethodExpandableViewModel) {
        self.selectionBtn.accessibilityIdentifier = viewModel.selectionButtonIdentifier
        self.titleLabel.accessibilityIdentifier = viewModel.titleIdentifier
        self.descriptionLabel.accessibilityIdentifier = viewModel.descriptionIdentifier
        self.expandableDescriptionLabel.accessibilityIdentifier = viewModel.selectDescriptionIdentifier
        self.lisboaTexFieldView.accessibilityIdentifier = viewModel.textFieldIdentifier
        self.minimumFeeLabel.accessibilityIdentifier = AccessibilityCardBoarding.ChangePayment.minFeeLabel.rawValue
    }
    
    func setLabelsText(from viewModel: PaymentMethodExpandableViewModel) {
        self.titleLabel.text = localized(viewModel.title)
        self.descriptionLabel.configureText(withKey: viewModel.description,
                                            andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .regular, size: 14),
                                                                                                 lineHeightMultiple: 0.85))
        self.expandableDescriptionLabel.configureText(withKey: viewModel.selectAmountDescription)
        self.minimumFeeLabel.configureText(withLocalizedString: localized(viewModel.minimunFee))
    }
    
    func setTextFieldEditingStyle() {
        self.lisboaTexFieldView.setRightAccessory(.image("icnArrowDown", action: {
            self.setDefaultPickerValue()
            self.textField?.becomeFirstResponder()
        }))
    }
    
    func setTextField(from viewModel: PaymentMethodExpandableViewModel) {
        let editingStyle = LisboaTextField.WritableTextField(
            type: .floatingTitle,
            formatter: nil,
            disabledActions: [],
            keyboardReturnAction: nil) { components in
                self.placeholderLabel = components.floatingLabel
                self.textField = components.textField
                self.setDefaultPickerValue()
        }
        self.lisboaTexFieldView.setEditingStyle(.writable(configuration: editingStyle))
        self.lisboaTexFieldView.setPlaceholder(localized(viewModel.placeHolder))
        self.placeholderLabel?.accessibilityIdentifier = viewModel.placeholderIdentifier
        self.setTextFieldDefaultValue()
    }
    
    func setTextFieldDefaultValue() {
        guard let viewModel = self.viewModel else { return }
        switch viewModel.paymentMethod {
        case .deferredPayment:
            self.lisboaTexFieldView.setText((viewModel.amount + "%"))
        case .fixedFee:
            self.lisboaTexFieldView.setText(viewModel.amount)
        case .monthlyPayment:
            self.lisboaTexFieldView.setText(viewModel.amount)
        }
    }
    
    func setViewStyle(_ viewState: PaymentMethodViewState) {
        switch viewState {
        case .selected:
            self.setSelectedStyle()
        case .deselected:
            self.setDeselectedStyle()
        }
    }
    
    func setSelectedStyle() {
        self.paymentMethodView?.backgroundColor = .darkTorquoise
        self.titleLabel.textColor = .white
        self.descriptionLabel.textColor = .white
        self.expandableView.isHidden = false
        self.expandableView.layoutIfNeeded()
        DispatchQueue.main.async {
            self.paymentMethodView.roundCorners(corners: [.topLeft, .topRight], radius: 6.0)
        }
    }
    
    func setDeselectedStyle() {
        self.expandableView.isHidden = true
        self.paymentMethodView?.backgroundColor = .white
        self.titleLabel.textColor = .lisboaGray
        self.descriptionLabel.textColor = .lisboaGray
        self.expandableView.layoutIfNeeded()
        DispatchQueue.main.async {
            self.paymentMethodView.roundCorners(corners: .allCorners, radius: 6.0)
        }
        self.setTextFieldDefaultValue()
        self.setDefaultPickerValue()
    }
    
    func updatePaymentMethod(_ amount: AmountEntity) {
        guard let newPaymentMethod = setNewPaymentMethod(amount) else { return }
        self.delegate?.didSelectPaymentMethodExpandable(newPaymentMethod)
    }
    
    func setNewPaymentMethod(_ amount: AmountEntity?) -> PaymentMethodCategory? {
        guard let viewModel = self.viewModel else { return nil }
        switch viewModel.paymentMethod {
        case .deferredPayment:
            return PaymentMethodCategory.deferredPayment(amount)
        case .fixedFee:
            return PaymentMethodCategory.fixedFee(amount)
        default:
            return nil
        }
    }
}

private extension PaymentMethodExpandableView {
    func setDefaultPickerValue() {
        guard let viewModel = self.viewModel, let textField = self.textField else { return }
        let defaultValue = viewModel.selectedIndex ?? viewModel.amountRangeValues[0]
        self.createPicker(textField: textField, row: defaultValue)
    }
    
    func createPicker(textField: UITextField, row: Int) {
        let picker = UIPickerView()
        picker.dataSource = self
        picker.delegate = self
        picker.showsSelectionIndicator = true
        picker.selectRow(row, inComponent: 0, animated: false)
        textField.inputView = picker
        guard let viewModel = self.viewModel else { return }
        picker.accessibilityIdentifier = viewModel.pickerIdentifier
    }
    
    func didSelectRow(_ row: Int) {
        guard let viewModel = self.viewModel else { return }
        switch viewModel.paymentMethod {
        case .deferredPayment:
            self.lisboaTexFieldView.setText("\(viewModel.amountValues[row])%")
        case .fixedFee:
            self.lisboaTexFieldView.setText("\(viewModel.amountValues[row])")
        case .monthlyPayment:
            self.lisboaTexFieldView.setText("\(viewModel.amountValues[row])")
        }
        let amount = AmountEntity(value: viewModel.amountValues[row])
        self.updatePaymentMethod(amount)
    }
    
    func getPickerValue() -> Int? {
        guard let picker = self.textField?.inputView as? UIPickerView else { return nil }
        return picker.selectedRow(inComponent: 0)
    }
}

extension PaymentMethodExpandableView: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        guard let viewModel = self.viewModel else { return nil }
        switch viewModel.paymentMethod {
        case .deferredPayment:
            return "\(viewModel.amountValues[row])%"
        case .fixedFee:
            return "\(viewModel.amountValues[row])"
        default:
            return ""
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.didSelectRow(row)
    }
}

extension PaymentMethodExpandableView: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        guard let viewModel = self.viewModel else { return 0 }
        return viewModel.amountValues.count
    }
}
