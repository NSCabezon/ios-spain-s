import UIKit
import UI
import Operative
import CoreFoundationLib
import IQKeyboardManagerSwift

public protocol TransferGenericAmountEntryViewProtocol: AnyObject, LoadingViewPresentationCapable {
    func setAccountInfo(_ accountViewModel: SelectedAccountHeaderViewModel)
    func setCountryAndCurrencyInfo(_ sepaInfoList: SepaInfoListEntity, countrySelected: SepaCountryInfoEntity, currencySelected: SepaCurrencyInfoEntity)
    func setLocationsCandidates(_ locations: [PullOfferLocation: OfferEntity])
    func updateContinueAction(_ enable: Bool)
    func showFaqs(_ items: [FaqsItemViewModel])
    func showInvalidAmount(_ error: String)
    func clearInvalidAmount()
    func setAmountAndConcept(amount: Decimal?, concept: String?)
    func disableDestinationCountrySelection()
    func disableAmountSelection()
}

public class TransferGenericAmountEntryViewController: UIViewController {
    @IBOutlet private weak var originAccountView: SelectedAccountHeaderView!
    @IBOutlet weak var destinationCountryTextField: ActionLisboaTextField! {
        didSet {
            self.presenter.fields.append(destinationCountryTextField)
            self.destinationCountryTextField.titleLabel.accessibilityIdentifier =  AccessibilityTransfers.inputDestinationCountryTitle.rawValue
            self.destinationCountryTextField.field.accessibilityIdentifier = AccessibilityTransfers.inputDestinationCountry.rawValue
            self.destinationCountryTextField.accessibilityIdentifier =  AccessibilityTransfers.inputDestinationCountryButton.rawValue
            self.destinationCountryTextField.updatableDelegate = self
            destinationCountryTextField.setArrowAccessibility(localized("voiceover_changeDestinationCountry"))
        }
    }

    @IBOutlet private var amountTextField: ActionLisboaTextField! {
        didSet {
            self.presenter.fields.append(amountTextField)
            self.amountTextField.titleLabel.accessibilityIdentifier = AccessibilityTransfers.inputAmountTitle.rawValue
            self.amountTextField.field.accessibilityIdentifier = AccessibilityTransfers.inputAmount.rawValue
            self.amountTextField.accessibilityIdentifier =  AccessibilityTransfers.inputAmountButton.rawValue
            self.amountTextField.updatableDelegate = self
        }
    }
    @IBOutlet weak var amountErrorView: UIView! {
        didSet {
            self.amountErrorView.isHidden = true
        }
    }
    @IBOutlet weak var amountErrorLabel: UILabel! {
        didSet {
            self.amountErrorLabel.setSantanderTextFont(type: .regular, size: 13, color: .bostonRed)
        }
    }

    @IBOutlet private var conceptTextField: LisboaTextfield! {
        didSet {
            self.conceptTextField.titleLabel.accessibilityIdentifier = AccessibilityTransfers.inputConceptTitle.rawValue
            self.conceptTextField.field.accessibilityIdentifier = AccessibilityTransfers.inputConcept.rawValue
        }
    }
    @IBOutlet private var separator: UIView!
    @IBOutlet private var continueButton: WhiteLisboaButton! {
        didSet {
            self.continueButton.accessibilityIdentifier = AccessibilityTransfers.btnContinue
        }
    }
    @IBOutlet private var scrollview: UIScrollView!
    @IBOutlet private var footerView: UIView!
    @IBOutlet private var bottomSpaceConstraint: NSLayoutConstraint!
    private var sepaInfoList: SepaInfoListEntity?
    private var countrySelected: SepaCountryInfoEntity?
    private var currencySelected: SepaCurrencyInfoEntity?
    private var pullOfferCandidates: [PullOfferLocation: OfferEntity]?
    private var amountText: String? {
        return amountTextField.text?.isEmpty ?? true ? nil : amountTextField.text
    }
    private var conceptText: String? {
        return self.conceptTextField.text?.isEmpty ?? true ? nil : self.conceptTextField.text
    }
    private var maxLengthConcept: Int {
        return self.dependenciesResolver.resolve(for: LocalAppConfig.self).maxLengthInternalTransferConcept
    }

    public let keyboardManager = KeyboardManager()

    let presenter: TransferGenericAmountEntryPresenterProtocol
    private let dependenciesResolver: DependenciesResolver

    // MARK: - Class Methods
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?,
         presenter: TransferGenericAmountEntryPresenterProtocol,
         dependenciesResolver: DependenciesResolver) {
        self.presenter = presenter
        self.dependenciesResolver = dependenciesResolver
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    public convenience init(presenter: TransferGenericAmountEntryPresenterProtocol, dependenciesResolver: DependenciesResolver) {
        self.init(nibName: "TransferGenericAmountEntryViewController", bundle: .module, presenter: presenter, dependenciesResolver: dependenciesResolver)
    }
    
    required public init?(coder: NSCoder) {
        fatalError()
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
        self.keyboardManager.setDelegate(self)
    }

    // MARK: - Actions Methods
    @IBAction func continueAction() {
        self.presenter.updateAmount(amountText)
        self.presenter.updateConcept(conceptText)
        self.presenter.onContinueButtonClicked()
    }
    
    private func continueActionTextfield(_ textfield: EditText) {
        self.continueAction()
    }
    
    @IBAction func editAccountAction() {
        self.presenter.changeAccountSelected()
    }
    
    public func getAmountAndConcept() -> (amount: String?, concept: String?) {
        return (self.amountText, self.conceptText)
    }
}

// MARK: - Private Methods

private extension TransferGenericAmountEntryViewController {
    func setupView() {
        self.view.backgroundColor = UIColor.white
        self.separator.backgroundColor = UIColor.mediumSkyGray
        self.originAccountView.backgroundColor = UIColor.skyGray
        self.continueButton.setTitle(localized("generic_button_continue"), for: .normal)
        self.continueButton.addSelectorAction(target: self, #selector(continueAction))
        self.setupDestinationTextField()
        self.setupAmountTextField()
        let conceptFormmater = UIFormattedCustomTextField()
        conceptFormmater.setMaxLength(maxLength: self.maxLengthConcept)
        self.conceptTextField.configure(with: conceptFormmater, title: localized("sendMoney_label_optionalConcept"), extraInfo: nil)
        conceptFormmater.setAllowOnlyCharacters(.sendMoneyOperative)
    }

    func setupDestinationTextField() {
        self.destinationCountryTextField.configure(with: nil,
                                                   actionViewStyle: .arrow,
                                                   title: localized("sendMoney_label_destinationCountry"),
                                                   disabledActions: TextFieldActions.usuallyDisabledActions,
                                                   badgeAccessibilityIdentifier: AccessibilityTransfers.countryBadgeBtn)
        self.destinationCountryTextField.disableTextFieldEditing()
        self.destinationCountryTextField.addExtraAction { [weak self] in
                guard let countrySelected = self?.countrySelected else { return }
                self?.showSearchForOperation(.countries, itemSelected: countrySelected)
        }
    }
    
    func setupAmountTextField() {
        let amountFormatter = UIAmountTextFieldFormatter()
        amountFormatter.delegate = self
        self.amountTextField.configure(with: amountFormatter,
                                       actionViewStyle: .arrow,
                                       title: localized("generic_hint_amount"),
                                       badgeAccessibilityIdentifier: AccessibilityTransfers.currencyBadgeBtn)
        self.amountTextField.field.keyboardType = .decimalPad
        self.amountTextField.keyboardToolbar.doneBarButton.setTarget(self, action: #selector(self.dismissKeyboard))
        _ = self.amountTextField.becomeFirstResponder()
        let isEnabledChangeCurrency = self.dependenciesResolver.resolve(for: LocalAppConfig.self).isEnabledChangeCurrency
        if isEnabledChangeCurrency {
            self.amountTextField.addExtraAction { [weak self] in
                guard let currencySelected = self?.currencySelected else { return }
                self?.showSearchForOperation(.currency, itemSelected: currencySelected)
            }
        } else {
            self.amountTextField.hideArrowStyleImage()
        }
    }
    
    @objc func dismissKeyboard() {
        self.amountTextField.field.endEditing(true)
    }
    
    func showSearchForOperation(_ operation: SepaSearchOperation, itemSelected: CountryCurrencyItemConformable?) {
        guard
            let sepaInfoList = self.sepaInfoList,
            let itemSelected = itemSelected,
            let candidates = self.pullOfferCandidates
            else { return }
        let presenter = CurrencyCountryFinderPresenter(operation: operation, sepaInfoList: sepaInfoList, itemSelected: itemSelected, pullOfferCandidates: candidates)
        let countryCurrencyFilterViewController = CurrencyCountryFinderViewController(presenter: presenter)
        countryCurrencyFilterViewController.delegate = self
        presenter.view = countryCurrencyFilterViewController
        countryCurrencyFilterViewController.modalPresentationStyle = .fullScreen
        self.present(countryCurrencyFilterViewController, animated: true, completion: nil)
    }
    
    func updateCountryTextField(_ country: SepaCountryInfoEntity) {
        self.destinationCountryTextField.updateActionLabel(country.code)
        self.destinationCountryTextField.updateData(text: country.name)
    }
    
    func updateCurrencyTextField(_ currency: SepaCurrencyInfoEntity) {
        self.amountTextField.updateActionLabel(currency.code)
    }
}

extension TransferGenericAmountEntryViewController: KeyboardManagerDelegate {
    public var keyboardButton: KeyboardManager.ToolbarButton? {
        return KeyboardManager.ToolbarButton(title: localized("generic_button_continue"), accessibilityIdentifier: AccessibilityTransfers.transferAmountEntryBtnContinue.rawValue, action: self.continueActionTextfield)
    }
    
    public var associatedScrollView: UIScrollView? {
        return self.scrollview
    }
}

extension TransferGenericAmountEntryViewController: TransferGenericAmountEntryViewProtocol {
    public func setLocationsCandidates(_ locations: [PullOfferLocation: OfferEntity]) {
        self.pullOfferCandidates = locations
    }
    
    public func setAccountInfo(_ accountViewModel: SelectedAccountHeaderViewModel) {
        self.originAccountView.setup(with: accountViewModel)
    }
    
    public func setCountryAndCurrencyInfo(_ sepaInfoList: SepaInfoListEntity, countrySelected: SepaCountryInfoEntity, currencySelected: SepaCurrencyInfoEntity) {
        self.sepaInfoList = sepaInfoList
        self.countrySelected = countrySelected
        self.currencySelected = currencySelected
        self.updateCountryTextField(countrySelected)
        self.updateCurrencyTextField(currencySelected)
    }

    public func updateContinueAction(_ enable: Bool) {
        self.continueButton.setIsEnabled(enable)
        self.keyboardManager.setKeyboardButtonEnabled(enable)
    }

    public func showFaqs(_ items: [FaqsItemViewModel]) {
        let data = FaqsViewData(items: items)
        data.show(in: self)
    }

    public func showInvalidAmount(_ error: String) {
        guard amountErrorView.isHidden else { return }
        self.amountErrorView.isHidden = false
        self.amountErrorLabel.text = error
        self.amountTextField.setErrorAppearance()
    }

    public func clearInvalidAmount() {
        guard !amountErrorView.isHidden else { return }
        self.amountErrorView.isHidden = true
        self.amountTextField.clearErrorAppearanceWithTitleVisible()
    }
    
    public func setAmountAndConcept(amount: Decimal?, concept: String?) {
        self.amountTextField.setText(amount?.getLocalizedStringValue())
        self.conceptTextField.updateData(text: concept)
    }
    
    public func disableDestinationCountrySelection() {
        self.destinationCountryTextField.addExtraAction(nil)
        self.destinationCountryTextField.hideArrowStyleImage()
    }
    
    public func disableAmountSelection() {
        self.amountTextField.addExtraAction(nil)
        self.amountTextField.hideArrowStyleImage()
    }
}

extension TransferGenericAmountEntryViewController: CurrencyCountryFinderViewControllerDelegate {
    func didSelectCloseBanner(_ offerId: String?) {
        self.presenter.closeLocationBanner(offerId)
    }
    
    func didSelectBanner() {
        self.presenter.selectLocationBanner()
    }
    
    func didSelectCurrency(_ currency: SepaCurrencyInfoEntity) {
        self.currencySelected = currency
        if self.self.dependenciesResolver.resolve(for: LocalAppConfig.self).isEnabledChangeCurrency {
            self.updateCurrencyTextField(currency)
            self.presenter.updateCurrency(currency)
        }
        
    }
    
    func didSelectCountry(_ country: SepaCountryInfoEntity, currency: SepaCurrencyInfoEntity) {
        self.countrySelected = country
        self.updateCountryTextField(country)
        self.presenter.updateCountry(country)
        self.didSelectCurrency(currency)
    }
}

extension TransferGenericAmountEntryViewController: UITextFieldDelegate {
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        IQKeyboardManager.shared.enableAutoToolbar = true
        IQKeyboardManager.shared.toolbarDoneBarButtonItemText = localized("generic_button_acceptKeyboard")
        IQKeyboardManager.shared.toolbarTintColor = .santanderRed
        return true
    }

    public func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        IQKeyboardManager.shared.enableAutoToolbar = false
        IQKeyboardManager.shared.toolbarDoneBarButtonItemText = nil
        return true
    }
}

extension TransferGenericAmountEntryViewController: UpdatableTextFieldDelegate {
    public func updatableTextFieldDidUpdate() {
        self.presenter.validatableFieldChanged()
        self.clearInvalidAmount()
    }
}

private extension TransferGenericAmountEntryViewController {
    func showComingSoonMessage() {
        Toast.show(localized("generic_alert_notAvailableOperation"))
    }
}
