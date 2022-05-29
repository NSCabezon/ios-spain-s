import CoreFoundationLib
import Operative
import UI

protocol SelectAmortizationStepViewProtocol: OperativeView {
    func setupHeader(_ model: SelectAmortizationHeaderViewModel)
    func enableContinueButton()
    func disableContinueButton()
    var advanceTextfield: LisboaTextField { get }
    var decreaseTextfield: LisboaTextField { get }
    func showErrorDialogWith(error: String)
}

final class SelectAmortizationStepViewController: UIViewController {
    @IBOutlet private var containerStackView: UIStackView!
    @IBOutlet private var bottomSeparatorView: UIView!
    @IBOutlet private var continueButton: WhiteLisboaButton!
    private let presenter: SelectAmortizationStepPresenterProtocol
    private let headerView = SelectAmortizationStepHeaderView()
    private var advanceOption = RadioTooltipItemView()
    private var decreaseOption = RadioTooltipItemView()
    var advanceTextfield = LisboaTextField()
    var decreaseTextfield = LisboaTextField()
    private var advanceView = UIView()
    private var decreaseView = UIView()

    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, presenter: SelectAmortizationStepPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
        self.presenter.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.replaceSwipeWithBack()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.resetSwipe()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

private extension SelectAmortizationStepViewController {
    func replaceSwipeWithBack() {
        presenter.container?.handler?.operativeNavigationController?.interactivePopGestureRecognizer?.isEnabled = true
        presenter.container?.handler?.operativeNavigationController?.interactivePopGestureRecognizer?.addTarget(self, action: #selector(handlePopGesture))
    }

    func resetSwipe() {
        presenter.container?.handler?.operativeNavigationController?.interactivePopGestureRecognizer?.removeTarget(self, action: nil)
    }

    @objc func handlePopGesture(gesture: UIGestureRecognizer) {
        if gesture.state == .began {
            presenter.container?.handler?.operativeNavigationController?.interactivePopGestureRecognizer?.isEnabled = false
            presenter.didSelectBack()
        }
    }
    
    func setupView() {
        self.setupNavigationBar()
        self.setupButtons()
        self.bottomSeparatorView.backgroundColor = .mediumSkyGray
        self.addSubviews()
        self.setAccesibilityIdentifiers()
    }

    func setupNavigationBar() {
        let builder = NavigationBarBuilder(
            style: .sky,
            title: .title(key: "toolbar_title_anticipatedAmortization")
        )
        builder.setLeftAction(.back(action: #selector(self.didSelectBack)))
        builder.setRightActions(
            NavigationBarBuilder.RightAction.close(action: #selector(self.didSelectClose))
        )
        builder.build(on: self, with: nil)
    }

    func setAccesibilityIdentifiers() {
        self.continueButton.accessibilityIdentifier = AccessibilityLoanAmortizationSelect.buttonContinue
        self.advanceTextfield.accessibilityIdentifier = AccessibilityLoanAmortizationSelect.textfieldAmount
        self.decreaseTextfield.accessibilityIdentifier = AccessibilityLoanAmortizationSelect.textfieldAmount
    }

    @objc func didSelectClose() {
        self.presenter.didSelectClose()
    }

    @objc func didSelectBack() {
        self.presenter.didSelectBack()
    }

    func setupButtons() {
        self.continueButton.setTitle(localized("generic_button_continue"), for: .normal)
        self.continueButton.addAction { [weak self] in
            self?.presenter.continueButtonPressed()
        }
        self.disableContinueButton()
    }

    func addSubviews() {
        self.view?.backgroundColor = .white
        self.setupAdvanceOptionView()
        self.setupDecreaseOptionView()
        self.advanceView = self.formattedAdvanceTextfield()
        self.decreaseView = self.formattedDecreaseTextfield()
        self.containerStackView.addArrangedSubview(self.headerView)
        self.containerStackView.addArrangedSubview(self.titleView())
        self.containerStackView.addArrangedSubview(self.advanceOption)
        self.containerStackView.addArrangedSubview(self.advanceView)
        self.containerStackView.addArrangedSubview(self.separatorView())
        self.containerStackView.addArrangedSubview(self.decreaseOption)
        self.containerStackView.addArrangedSubview(self.decreaseView)
        self.containerStackView.addArrangedSubview(self.separatorView())
        self.containerStackView.addArrangedSubview(UIView())
        self.advanceView.isHidden = true
        self.decreaseView.isHidden = true
    }

    func titleView() -> UIView {
        let containerView = UIView()
        let label = UILabel()
        label.textColor = .lisboaGray
        let labelTextConfiguration = LocalizedStylableTextConfiguration(font: UIFont.santander(size: 18), alignment: .left)
        label.configureText(withKey: "amortization_label_typeAmortization",
                            andConfiguration: labelTextConfiguration)
        label.accessibilityIdentifier = AccessibilityLoanAmortizationSelect.labelTitle
        containerView.addSubview(label)
        label.fullFit(topMargin: 18, bottomMargin: 18, leftMargin: 16, rightMargin: 16)
        return containerView
    }

    func setupAdvanceOptionView() {
        let info: String = localized("tooltip_text_advanceExpiration")
        let viewModelAdvance = RadioTooltipItemViewModel(
            title: localized("anticipatedAmortization_label_advanceExpiration"),
            tooltipInfo: localized("tooltip_text_advanceExpiration"),
            accessibilityId: "anticipatedAmortization_label_advanceExpiration",
            isSelected: false,
            isDeselectingAllowed: false
        )
        self.advanceOption.setup(with: viewModelAdvance)
        self.advanceOption.delegate = self
    }

    func setupDecreaseOptionView() {
        let info: String = localized("tooltip_text_decreaseFee")
        let viewModelDecrease = RadioTooltipItemViewModel(
            title: localized("anticipatedAmortization_label_decreaseFee"),
            tooltipInfo: localized("tooltip_text_decreaseFee"),
            accessibilityId: "anticipatedAmortization_label_decreaseFee",
            isSelected: false,
            isDeselectingAllowed: false
        )
        self.decreaseOption.setup(with: viewModelDecrease)
        self.decreaseOption.delegate = self
    }

    func formattedAdvanceTextfield() -> UIView {
        let containerView = UIView()
        let amountFormatter = UIAmountTextFieldFormatter()
        self.advanceTextfield.setEditingStyle(.writable(configuration: LisboaTextField.WritableTextField(type: .floatingTitle, formatter: amountFormatter, textfieldCustomizationBlock: self.setupTextField(_:))))
        self.advanceTextfield.setPlaceholder(localized("generic_hint_amount"))
        self.advanceTextfield.setStyle(.default)
        self.advanceTextfield.updatableDelegate = self.presenter
        self.advanceTextfield.setRightAccessory(.image("icnEuro", action: {}))
        containerView.addSubview(self.advanceTextfield)
        self.advanceTextfield.heightAnchor.constraint(equalToConstant: 58).isActive = true
        self.advanceTextfield.fullFit(topMargin: 0, bottomMargin: 16, leftMargin: 16, rightMargin: 16)
        return containerView
    }

    func formattedDecreaseTextfield() -> UIView {
        let containerView = UIView()
        let amountFormatter = UIAmountTextFieldFormatter()
        self.decreaseTextfield.setEditingStyle(.writable(configuration: LisboaTextField.WritableTextField(type: .floatingTitle, formatter: amountFormatter, textfieldCustomizationBlock: self.setupTextField(_:))))
        self.decreaseTextfield.setPlaceholder(localized("generic_hint_amount"))
        self.decreaseTextfield.setStyle(.default)
        self.decreaseTextfield.updatableDelegate = self.presenter
        self.decreaseTextfield.setRightAccessory(.image("icnEuro", action: {}))
        containerView.addSubview(self.decreaseTextfield)
        self.decreaseTextfield.heightAnchor.constraint(equalToConstant: 58).isActive = true
        self.decreaseTextfield.fullFit(topMargin: 0, bottomMargin: 16, leftMargin: 16, rightMargin: 16)
        return containerView
    }

    func separatorView() -> UIView {
        let containerView = UIView()
        let separator = UIView()
        separator.backgroundColor = .mediumSkyGray
        containerView.addSubview(separator)
        separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        separator.fullFit(topMargin: 0, bottomMargin: 0, leftMargin: 16, rightMargin: 16)
        return containerView
    }

    func setupTextField(_ component: LisboaTextField.CustomizableComponents) {
        component.textField.autocorrectionType = .no
        component.textField.spellCheckingType = .no
        component.textField.keyboardType = .decimalPad
    }
}

extension SelectAmortizationStepViewController: SelectAmortizationStepViewProtocol {
    var operativePresenter: OperativeStepPresenterProtocol {
        self.presenter
    }

    func setupHeader(_ model: SelectAmortizationHeaderViewModel) {
        self.headerView.setViewModel(model)
    }

    func enableContinueButton() {
        self.continueButton.setIsEnabled(true)
    }

    func disableContinueButton() {
        self.continueButton.setIsEnabled(false)
    }
    
    func showErrorDialogWith(error: String) {
        let action = Dialog.Action(title: localized("generic_button_accept"),
                                   style: .red,
                                   action: {})
        let styledText = LocalizedStylableText(text: error, styles: nil)
        let dialog = Dialog(title: nil,
                            items: [Dialog.Item.styledText(styledText, identifier: nil, hasTitleAndNotAlignment: false)],
                            image: nil,
                            actionButton: action,
                            isCloseButtonAvailable: false)
        dialog.show(in: self)
    }
}

extension SelectAmortizationStepViewController: RadioTooltipItemViewDelegate {
    func radioItemViewSelected(_ view: RadioTooltipItemView, viewModel: RadioTooltipItemViewModel) {
        if view == self.advanceOption, viewModel.isSelected {
            if !self.decreaseView.isHidden || (self.advanceView.isHidden && self.decreaseView.isHidden) { // First time
                self.presenter.newOptionSelected(.decreaseTime)
                self.decreaseTextfield.setText(nil)
            }
            self.advanceView.isHidden = false
            self.decreaseView.isHidden = true
            self.decreaseOption.viewModel.isSelected = false
        } else if view == self.decreaseOption, viewModel.isSelected {
            if !self.advanceView.isHidden || (self.advanceView.isHidden && self.decreaseView.isHidden) { // First time
                self.presenter.newOptionSelected(.decreaseFee)
                self.advanceTextfield.setText(nil)
            }
            self.advanceView.isHidden = true
            self.decreaseView.isHidden = false
            self.advanceOption.viewModel.isSelected = false
        }
    }
}
