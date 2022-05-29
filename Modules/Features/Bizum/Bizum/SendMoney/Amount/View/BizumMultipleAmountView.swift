import UIKit
import UI
import CoreFoundationLib
import ESUI

final class BizumMultipleAmountView: XibView {
    // MARK: - Public Var
    var amountWasUpdated: (String?) -> Void = { _ in }
    weak var presenter: BizumAmountPresenterProtocol? {
        didSet {
            self.presenter?.fields.append(amountTextField)
        }
    }
    // MARK: - Private Var
    private var amountTextField: LisboaTextField { return amountTextFieldWithErrorView.textField }
    private let amountFont = UIFont.santander(family: .text, type: .bold, size: 32.0)
    private var textFieldStyle: LisboaTextFieldStyle {
        var defaultStyle = LisboaTextFieldStyle.default
        defaultStyle.fieldTextColor = .lisboaGray
        defaultStyle.extraInfoHorizontalSeparatorBackgroundColor = .darkTurqLight
        return defaultStyle
    }

    @IBOutlet var contentView: UIView!
    @IBOutlet private weak var amountTextFieldWithErrorView: LisboaTextFieldWithErrorView! {
        didSet {
            self.amountTextFieldWithErrorView.textField.accessibilityIdentifier = AccessibilityBizumSendMoney.bizumInputAmount
            self.amountTextFieldWithErrorView.setHeight(48)
            self.amountTextField.setEditingStyle(.writable(configuration: LisboaTextField.WritableTextField(type: .floatingTitle,
                                                                                                            formatter: UIAmountTextFieldFormatter(),
                                                                                                            disabledActions: [],
                                                                                                            keyboardReturnAction: nil,
                                                                                                            textfieldCustomizationBlock: self.setupTextField(_:))))
            self.amountTextField.setStyle(textFieldStyle)
            self.amountTextField.placeholder = localized("bizum_hint_AmountPerson")
            self.amountTextField.setRightAccessory(.uiImage(ESAssets.image(named: "icnBizumEuroAmount18"),
                                                            action: {}
            ))
            self.amountTextField.updatableDelegate = self
        }
    }
    @IBOutlet private weak var conceptLisboaTextField: LisboaTextField! {
        didSet {
            self.conceptLisboaTextField.accessibilityIdentifier = AccessibilityBizumSendMoney.bizumInputConcept
            self.conceptLisboaTextField.updatableDelegate = self
        }
    }
    @IBOutlet private weak var stackView: UIStackView! {
        didSet {
            self.stackView.accessibilityIdentifier = AccessibilityBizumSendMoney.bizumListContacts
        }
    }
    @IBOutlet private weak var totalAmountLabel: UILabel! {
        didSet {
            self.totalAmountLabel.font = .santander(family: .text, type: .regular, size: 12)
            self.totalAmountLabel.textColor = .grafite
            self.totalAmountLabel.text = localized("bizum_hint_totalAmount")
            self.totalAmountLabel.accessibilityIdentifier = AccessibilityBizumSendMoney.bizumLabelTotalAmount
        }
    }
    @IBOutlet private weak var amountValue: UILabel! {
        didSet {
            self.amountValue.font = .santander(family: .text, type: .bold, size: 32)
            self.amountValue.textColor = .lisboaGray
            self.amountValue.adjustsFontSizeToFitWidth = true
            self.amountValue.minimumScaleFactor = 0.5
            self.amountValue.numberOfLines = 1
            self.amountValue.accessibilityIdentifier = AccessibilityBizumSendMoney.bizumlabelTotal

        }
    }
    @IBOutlet private weak var sameAmountLabel: UILabel! {
        didSet {
            self.sameAmountLabel.font = .santander(family: .text, type: .regular, size: 12)
            self.sameAmountLabel.textColor = .grafite
            self.sameAmountLabel.accessibilityIdentifier = AccessibilityBizumSendMoney.bizumTooltipSameAmount
        }
    }
    @IBOutlet private weak var separatorTopView: UIView! {
        didSet {
            self.separatorTopView.backgroundColor = .mediumSky
        }
    }
    @IBOutlet private weak var separatorBottomView: UIView! {
        didSet {
            self.separatorBottomView.backgroundColor = .mediumSky
        }
    }
    @IBOutlet private var amountHeightConstraint: NSLayoutConstraint!

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configureView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.configureView()
    }
}

extension BizumMultipleAmountView: BizumMultipleAmountViewProtocol {
    func showTotalAmount(_ amount: Decimal) {
        let amountAttribute = MoneyDecorator(AmountEntity(value: amount), font: amountFont, decimalFontSize: 18.0).formatAsMillions()
        self.amountValue.attributedText = amountAttribute
    }

    func show(amount: Decimal, contacts: [BizumContactDetailModel]) {
        let amount = MoneyDecorator(AmountEntity(value: amount), font: amountFont, decimalFontSize: 18.0).formatAsMillions()
        self.amountValue.attributedText = amount
        contacts.enumerated().forEach { (index, destinationDetail) in
            let destinationDetailView = BizumContactDetailView()
            let destinationViewModel = BizumContactDetailViewModel(destinationDetail: destinationDetail)
            destinationViewModel.view = destinationDetailView
            destinationViewModel.updateView()
            if index == contacts.count - 1 {
                destinationViewModel.hideSeparator()
            }
            self.stackView.addArrangedSubview(destinationDetailView)
        }
    }
    
    func preloadAmountPerDestination(_ amount: String) {
        self.amountTextField.setText(amount)
        self.presenter?.validatableFieldChanged()
    }
    
    func showConcept(_ concept: String) {
        self.conceptLisboaTextField.setText(concept)
    }

    func updateAllDestinationsAmount(_ amount: NSAttributedString) {
        self.stackView.subviews.forEach { (view) in
            guard let view = view as? BizumContactDetailViewProtocol else { return }
            view.showAmount(amount)
        }
    }
    
    func showHintAmountValue(_ value: String) {
        self.sameAmountLabel.text = "* \(localized(value))"
    }
}

extension BizumMultipleAmountView: UpdatableTextFieldDelegate {
    func updatableTextFieldDidUpdate() {
        self.presenter?.validatableFieldChanged()
        self.amountWasUpdated(amountTextField.fieldValue)
    }
}

extension BizumMultipleAmountView: SendingInformationBizumDelegate {
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
    
    func setConcept(_ value: String) {
        self.conceptLisboaTextField.setText(value)
    }
}

private extension BizumMultipleAmountView {
    func configureView() {
        self.configureConceptTextField()
    }

    func setupTextField(_ component: LisboaTextField.CustomizableComponents) {
        component.textField.keyboardType = .decimalPad
    }

    func configureConceptTextField() {
        let conceptFormat = UIFormattedCustomTextField()
        var conceptTextFieldStyle = LisboaTextFieldStyle.default
        conceptTextFieldStyle.fieldTextColor = .lisboaGray
        conceptFormat.setMaxLength(maxLength: 35)
        conceptFormat.setAllowOnlyCharacters(.bizumConcept)
        self.conceptLisboaTextField.setEditingStyle(.writable(configuration: LisboaTextField.WritableTextField(type: .floatingTitle,
                                                                                                               formatter: conceptFormat,
                                                                                                               disabledActions: [],
                                                                                                               keyboardReturnAction: nil,
                                                                                                               textfieldCustomizationBlock: nil)))
        self.conceptLisboaTextField.setStyle(conceptTextFieldStyle)
        self.conceptLisboaTextField.placeholder = localized("bizum_hint_concept")
    }
}
