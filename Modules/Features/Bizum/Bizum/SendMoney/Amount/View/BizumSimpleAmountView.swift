import UIKit
import UI
import CoreFoundationLib
import ESUI

protocol BizumSimpleAmountViewProtocol {
    func setViewModel(_ viewModel: BizumSimpleAmountViewModel)
}

final class BizumSimpleAmountView: XibView {
    var amountTextFieldDelegate: UITextFieldDelegate? {
        didSet {
            self.amountTextField.fieldDelegate = amountTextFieldDelegate
        }
    }
    var presenter: ValidatableFormPresenterProtocol? {
        didSet {
            self.presenter?.fields.append(amountTextField)
        }
    }
    weak var updatableSendingMoneyDelegate: BizumUpdatableSendingMoneyDelegate?
    private var amountTextField: LisboaTextField { return amountTextFieldWithErrorView.textField }
    private var amountTextFieldStyle: LisboaTextFieldStyle {
        var defaultStyle = LisboaTextFieldStyle.default
        defaultStyle.fieldFont = .santander(family: .text, type: .bold, size: 55)
        defaultStyle.fieldTextColor = .lisboaGray
        defaultStyle.titleLabelFont = .santander(family: .text, type: .regular, size: 14)
        defaultStyle.titleLabelTextColor = .mediumSanGray
        defaultStyle.extraInfoHorizontalSeparatorBackgroundColor = .darkTurqLight
        return defaultStyle
    }

    @IBOutlet var contentView: UIView!
    @IBOutlet private weak var amountTextFieldWithErrorView: LisboaTextFieldWithErrorView! {
        didSet {
            self.amountTextFieldWithErrorView.textField.accessibilityIdentifier = AccessibilityBizumSendMoney.bizumInputAmount
            self.amountTextFieldWithErrorView.setHeight(106)
            let amountFormatter = UIAmountTextFieldFormatter()
            self.amountTextField.setEditingStyle(.writable(configuration: LisboaTextField.WritableTextField(type: .floatingTitle,
                                                                                                            formatter: amountFormatter,
                                                                                                            disabledActions: [],
                                                                                                            keyboardReturnAction: nil,
                                                                                                            textfieldCustomizationBlock: self.setupAmountTextField(_:))))
            self.amountTextField.setStyle(amountTextFieldStyle)
            self.amountTextField.separatorMargin = 20.0
            self.amountTextField.placeholder = localized("generic_hint_amount")
            self.amountTextField.setRightAccessory(.uiImage(ESAssets.image(named: "icnBizumEuroAmount"),
                                                            action: {}
            ))
            self.amountTextField.updatableDelegate = self
        }
    }
    @IBOutlet private weak var conceptLisboaTextField: LisboaTextField! {
        didSet {
            self.conceptLisboaTextField.accessibilityIdentifier = AccessibilityBizumSendMoney.bizumInputConcept
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configureView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.configureView()
    }
}

extension BizumSimpleAmountView: BizumSimpleAmountViewProtocol {
    func setViewModel(_ viewModel: BizumSimpleAmountViewModel) {
        self.amountTextFieldWithErrorView.textField.setText(viewModel.amount)
        self.conceptLisboaTextField.setText(viewModel.concept)
        self.presenter?.validatableFieldChanged()
    }
}
extension BizumSimpleAmountView: UpdatableTextFieldDelegate {
    func updatableTextFieldDidUpdate() {
        self.presenter?.validatableFieldChanged()
        self.updatableSendingMoneyDelegate?.updateSendingAmount(amountTextField.fieldValue?.stringToDecimal ?? 0)
    }
}

extension BizumSimpleAmountView: SendingInformationBizumDelegate {
    func getConcept() -> String? {
        return self.conceptLisboaTextField.text
    }

    func showAmountError(_ error: String) {
        self.amountTextFieldWithErrorView.showError(error)
    }

    func hideAmountError() {
        self.amountTextFieldWithErrorView.hideError()
    }

    func setAmountFocused() {
        self.amountTextFieldWithErrorView.textField.setTextFieldFocus()
    }
}

private extension BizumSimpleAmountView {
    func configureView() {
        self.configureConceptTextField()
        self.amountTextFieldWithErrorView.textField.textFieldPlaceholder = "0,00"
    }

    func configureConceptTextField() {
        let conceptFormat = UIFormattedCustomTextField()
        conceptFormat.setMaxLength(maxLength: 35)
        conceptFormat.setAllowOnlyCharacters(.bizumConcept)
        self.conceptLisboaTextField.setEditingStyle(.writable(configuration: LisboaTextField.WritableTextField(type: .floatingTitle,
                                                                                                               formatter: conceptFormat,
                                                                                                               disabledActions: [],
                                                                                                               keyboardReturnAction: nil,
                                                                                                               textfieldCustomizationBlock: nil)))
        var conceptTextFieldStyle = LisboaTextFieldStyle.default
        conceptTextFieldStyle.fieldTextColor = .lisboaGray
        self.conceptLisboaTextField.setStyle(conceptTextFieldStyle)
        self.conceptLisboaTextField.placeholder = localized("bizum_hint_concept")
    }

    func setupAmountTextField(_ component: LisboaTextField.CustomizableComponents) {
        component.textField.keyboardType = .decimalPad
    }
}
