import UIKit
import UI
import CoreFoundationLib

public protocol TransferDestinationViewProtocol: AnyObject, LoadingViewPresentationCapable {
    func setAccountInfo(_ accountViewModel: SelectedAccountHeaderViewModel)
    func setListFavourites(_ viewModels: [ContactViewModel], sepaInfoList: SepaInfoListEntity)
    func setLastTransfers(_ viewModels: [EmittedSepaTransferViewModel], isFavouritesCarrouselEnabled: Bool)
    func setHiddenLastTransfers()
    func updateContinueAction(_ enable: Bool)
    func addAliasTextValidation()
    func removeAliasTextValidation()
    func showInvalidIban(_ errorKey: String)
    func hideInvalidIban()
    func updateBeneficiaryInfo(_ name: String?, iban: String?, alias: String?, isFavouriteSelected: Bool)
    func hideDestinationViews(isEnableResidence: Bool, isEnabledSelectorBusinessDateView: Bool)
    func setupPeriodicityModel(with model: SendMoneyPeriodicityViewModel)
    func setCountry(_ countryName: String)
    func configureIbanWithBankingUtils(_ bankingUtils: BankingUtilsProtocol, controlDigitDelegate: IbanCccTransferControlDigitDelegate?)
    func updateInfo()
    func setDateTypeSaved(dateTypeModel: SendMoneyDateTypeFilledViewModel)
    func disableEditingDestinationInformation()
}

public final class TransferDestinationViewController: UIViewController {
    let presenter: TransferDestinationPresenterProtocol
    @IBOutlet private weak var originAccountView: SelectedAccountHeaderView!
    @IBOutlet private var separator: UIView!
    @IBOutlet private var continueButton: WhiteLisboaButton! {
        didSet {
            self.continueButton.accessibilityIdentifier = AccessibilityTransfers.btnContinue
        }
    }
    @IBOutlet private var footerView: UIView!
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var lastBeneficiariesView: LastBeneficiariesView!
    @IBOutlet private weak var recipientListTextField: ActionLisboaTextField! {
        didSet {    
            self.presenter.fields.append(self.recipientListTextField)
            self.recipientListTextField.field.accessibilityIdentifier = AccessibilityFavRecipients.favouriteTf
            self.recipientListTextField.updatableDelegate = self
            self.recipientListTextField.field.addTarget(self, action: #selector(setContinueToolbarAction), for: .editingDidBegin)
        }
    }
    @IBOutlet private weak var ibanTransferView: IbanCccTransferView! {
        didSet {
            self.presenter.fields.append(self.ibanTransferView.ibanLisboaTextField)
            self.ibanTransferView.updatableDelegate = self
            self.ibanTransferView.delegate = self
        }
    }
    @IBOutlet private weak var residenceCheckboxButton: UIButton!
    @IBOutlet private weak var residenceLabel: UILabel!
    @IBOutlet private weak var saveContactView: UIView!
    @IBOutlet private weak var saveContactCheckboxButton: UIButton!
    @IBOutlet private weak var saveContactLabel: UILabel!
    @IBOutlet private weak var aliasView: UIView!
    @IBOutlet private weak var aliasTextField: LisboaTextfield! {
        didSet {
            self.aliasTextField.field.addTarget(self, action: #selector(setContinueToolbarAction), for: .editingDidBegin)
        }
    }
    @IBOutlet private weak var dateSelectorView: SendMoneyDateSelector!
    @IBOutlet private weak var residenceCheckboxView: UIView!
    private var favouritesListViewModel: [ContactViewModel]?
    private var country: String?
    private var lastTransfersViewModel: [EmittedSepaTransferViewModel]?
    private var maxLengthAlias: Int {
        return presenter.getMaxLengthAlias()
    }
    private let maxLengthRecipient = 70
    private let maxLastBeneficiaries = 20
    private var sepaInfoList: SepaInfoListEntity?
    public let keyboardManager = KeyboardManager()
    private var action: KeyboardManager.Action = .continueAction
    private var didChangeAliasCheck: Bool = true
    
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?,
         presenter: TransferDestinationPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    public convenience init(presenter: TransferDestinationPresenterProtocol) {
        self.init(nibName: "TransferDestinationViewController", bundle: .module, presenter: presenter)
    }
    
    required public init?(coder: NSCoder) {
        fatalError()
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
        self.setDelegates()
        self.configureCheckBox()
        self.configureLabelsGestures()
        self.presenter.viewDidLoad()
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.keyboardManager.update()
    }
    
    // MARK: - Actions Methods
    @IBAction func editAccountAction() {
        self.presenter.changeAccountSelected()
    }
    
    @IBAction func didPressCheckbox(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        self.changeCheckBoxButtonAccessibilityLabel()
        if sender == saveContactCheckboxButton {
            let isSelected = saveContactCheckboxButton.isSelected
            aliasView.isHidden = !isSelected
            if self.didChangeAliasCheck == true {
                self.presenter.didChangeAliasCheck(isSelected)
            }
            self.didChangeAliasCheck = true
        }
        if sender == residenceCheckboxButton {
            self.presenter.didChangeSpanishCheck(residenceCheckboxButton.isSelected)
        }
    }
    
    @IBAction func continueAction() {
        self.updateInfo()
        self.presenter.onContinueButtonClicked()
    }
    
    private func continueActionTextfield(_ textfield: EditText) {
        self.continueAction()
    }
}

// MARK: - Private Methods

private extension TransferDestinationViewController {
    func setupView() {
        self.view.backgroundColor = UIColor.white
        self.separator.backgroundColor = UIColor.mediumSkyGray
        self.originAccountView.backgroundColor = UIColor.skyGray
        self.continueButton.setTitle(localized("generic_button_continue"), for: .normal)
        self.continueButton.addSelectorAction(target: self, #selector(continueAction))
        self.configureRecipientListTextField()
        self.keyboardManager.update()
        self.dateSelectorView.setDefaultValues(addingDays: self.presenter.differenceOfDaysToDeferredTransfers())
    }
    
    func setDelegates() {
        self.dateSelectorView.delegate = self
        self.keyboardManager.setDelegate(self)
    }
    
    func didTapOnFavourites() {
        guard let favourites = self.favouritesListViewModel,
              let sepaInfoList = self.sepaInfoList,
              let country = self.country
        else { return }
        let favouritesViewModel: [ContactListItemViewModel] = favourites.map({ viewModel in
            return ContactListItemViewModel(contact: viewModel.contact,
                                            baseUrl: viewModel.baseUrl,
                                            sepaInfoList: sepaInfoList,
                                            colorsByNameViewModel: viewModel.colorsByNameViewModel,
                                            showCurrencySymbol: true)
        })
        let viewController = FavRecipientsViewController()
        viewController.viewModel = favouritesViewModel
        viewController.country = country
        viewController.recipientDelegate = self
        viewController.modalPresentationStyle = .fullScreen
        present(viewController, animated: true, completion: nil)
    }
    
    func setupBeneficiariesView(_ isFavouritesCarrouselEnabled: Bool) {
        guard let lastTransfers = self.lastTransfersViewModel else { return }
        let isHidden = lastTransfers.count <= 0 || !isFavouritesCarrouselEnabled
        self.lastBeneficiariesView.isHidden = isHidden
        if !isHidden {
            self.lastBeneficiariesView.delegate = self
        }
    }
    
    func setHiddenLastTransfersCarousel() {
        self.lastBeneficiariesView.isHidden = true
    }
    
    func configureCheckBox() {
        residenceCheckboxButton.setImage(Assets.image(named: "icnCheckBoxUnSelected"), for: .normal)
        residenceCheckboxButton.setImage(Assets.image(named: "icnCheckBoxSelectedGreen"), for: .selected)
        saveContactCheckboxButton.setImage(Assets.image(named: "icnCheckBoxUnSelected"), for: .normal)
        saveContactCheckboxButton.setImage(Assets.image(named: "icnCheckBoxSelectedGreen"), for: .selected)
        self.saveContactCheckboxButton.accessibilityIdentifier = AccessibilityTransferDestination.btnSaveCheckBox.rawValue
        residenceCheckboxButton.isSelected = true
        self.residenceCheckboxButton.accessibilityIdentifier = AccessibilityTransferDestination.btnResidentCheckBox.rawValue
        
        residenceLabel.setSantanderTextFont(type: .regular, size: 14, color: .grafite)
        residenceLabel.configureText(withKey: "sendMoney_label_residentsInSpain")
        self.residenceLabel.accessibilityIdentifier = AccessibilityTransferDestination.residentLabel.rawValue
        saveContactLabel.setSantanderTextFont(type: .regular, size: 14, color: .grafite)
        saveContactLabel.configureText(withKey: "sendMoney_label_checkSaveContact")
        self.saveContactLabel.accessibilityIdentifier = AccessibilityTransferDestination.saveLabel.rawValue
        
        let aliasFormat = UIFormattedCustomTextField()
        aliasFormat.setMaxLength(maxLength: maxLengthAlias)
        aliasTextField.configure(with: aliasFormat,
                                 title: localized("sendMoney_label_favoritesRecipientsAlias"),
                                 extraInfo: nil)
        self.aliasTextField.field.accessibilityIdentifier = AccessibilityTransferDestination.areaInputTextAlias.rawValue
        self.aliasTextField.writteButton.accessibilityIdentifier = AccessibilityTransferDestination.areaInputTextAlias.rawValue
        self.saveContactLabel.accessibilityElementsHidden = true
        self.saveContactCheckboxButton.accessibilityLabel = saveContactLabel.text ?? ""
        self.saveContactCheckboxButton.accessibilityTraits = .none
        self.changeCheckBoxButtonAccessibilityLabel()
        aliasFormat.setAllowOnlyCharacters(.sendMoneyOperative)
    }
    
    func configureLabelsGestures() {
        let residenceLabelTap = UITapGestureRecognizer(target: self, action: #selector(didTapResidenceLabel))
        let saveContactLabelTap = UITapGestureRecognizer(target: self, action: #selector(didTapSaveContactLabel))
        residenceLabel.addGestureRecognizer(residenceLabelTap)
        residenceLabel.isUserInteractionEnabled = true
        saveContactLabel.addGestureRecognizer(saveContactLabelTap)
        saveContactLabel.isUserInteractionEnabled = true
    }
    
    func updateFavouriteInfo(_ name: String?, iban: String?) {
        self.recipientListTextField.setText(name)
        self.ibanTransferView.setText(iban ?? "")
        self.recipientListTextField.textFieldDidEndEditing(self.recipientListTextField.field)
        self.presenter.didSelectBeneficiary(nil)
    }
    
    func updateFavouriteInfo(_ transferEmitted: TransferEmittedEntity) {
        self.presenter.didSelectBeneficiary(transferEmitted)
    }
    
    @objc func didTapResidenceLabel() {
        self.didPressCheckbox(residenceCheckboxButton)
    }
    
    @objc func didTapSaveContactLabel() {
        self.didPressCheckbox(saveContactCheckboxButton)
    }
    
    private func configureRecipientListTextField() {
        let recipientFormater = UIFormattedCustomTextField()
        recipientFormater.setMaxLength(maxLength: maxLengthRecipient)
        self.recipientListTextField.configure(with: recipientFormater, actionViewStyle: .image, title: localized("sendMoney_label_recipients"))
        self.recipientListTextField.addExtraAction({ [weak self] in self?.didTapOnFavourites() })
        self.recipientListTextField.field.isAccessibilityElement = true
        self.recipientListTextField.field.accessibilityFrame = self.recipientListTextField.frame
        self.recipientListTextField.field.accessibilityElementsHidden = false
        self.recipientListTextField.field.accessibilityLabel = localized("sendMoney_label_recipients")
        self.recipientListTextField.writeButton.accessibilityIdentifier = AccessibilityFavRecipients.favouriteTfButton
        self.recipientListTextField.actionView.accessibilityIdentifier = AccessibilityFavRecipients.favouriteButton
        recipientFormater.setAllowOnlyCharacters(.sendMoneyOperative)
    }
}

extension TransferDestinationViewController: TransferDestinationViewProtocol {
    public func configureIbanWithBankingUtils(_ bankingUtils: BankingUtilsProtocol,
                                              controlDigitDelegate: IbanCccTransferControlDigitDelegate?) {
        self.ibanTransferView.setBankingUtil(bankingUtils,
                                             controlDigitDelegate: controlDigitDelegate)
    }
    
    public func setAccountInfo(_ accountViewModel: SelectedAccountHeaderViewModel) {
        self.originAccountView.setup(with: accountViewModel)
    }
    
    public func setListFavourites(_ viewModels: [ContactViewModel], sepaInfoList: SepaInfoListEntity) {
        self.sepaInfoList = sepaInfoList
        self.favouritesListViewModel = viewModels
    }
    
    public func setCountry(_ countryName: String) {
        self.country = countryName
    }
    
    public func setLastTransfers(_ viewModels: [EmittedSepaTransferViewModel], isFavouritesCarrouselEnabled: Bool) {
        self.lastTransfersViewModel = viewModels
        if viewModels.count > 0 {
            let beneficiaries = viewModels.prefix(maxLastBeneficiaries)
            self.lastBeneficiariesView.setViewModels(Array(beneficiaries))
        }
        self.setupBeneficiariesView(isFavouritesCarrouselEnabled)
    }
    
    public func setHiddenLastTransfers() {
        self.setHiddenLastTransfersCarousel()
    }
    
    public func updateContinueAction(_ enable: Bool) {
        self.continueButton.setIsEnabled(enable)
        self.keyboardManager.setKeyboardButtonEnabled(enable)
    }
    
    public func addAliasTextValidation() {
        self.presenter.fields.append(self.aliasTextField)
        self.aliasTextField.updatableDelegate = self
        self.keyboardManager.update()
        _ = self.aliasTextField.becomeFirstResponder()
        self.presenter.validatableFieldChanged()
    }
    
    public func removeAliasTextValidation() {
        self.presenter.fields.removeAll { self.aliasTextField.isEqual($0) }
        self.aliasTextField.updatableDelegate = nil
        self.view.endEditing(true)
        self.presenter.validatableFieldChanged()
        self.keyboardManager.update()
    }
    
    public func showInvalidIban(_ errorKey: String) {
        self.ibanTransferView.showError(errorKey)
    }
    
    public func hideInvalidIban() {
        self.ibanTransferView.hideError()
    }
    
    @objc func setContinueToolbarAction() {
        self.action = .continueAction
        self.keyboardManager.setDelegate(self)
        self.presenter.validatableFieldChanged()
    }
    
    public func updateBeneficiaryInfo(_ name: String?, iban: String?, alias: String?, isFavouriteSelected: Bool) {
        self.recipientListTextField.setText(name)
        self.ibanTransferView.setText(iban ?? "")
        if isFavouriteSelected == true, self.saveContactCheckboxButton.isSelected == false {
            self.didChangeAliasCheck = false
            self.didPressCheckbox(saveContactCheckboxButton)
        }
        if alias?.isEmpty == false {
            self.aliasTextField.updateData(text: alias)
        }
        self.aliasTextField.resignFirstResponder()
        self.recipientListTextField.textFieldDidEndEditing(self.recipientListTextField.field)
    }
    
    public func hideDestinationViews(isEnableResidence: Bool, isEnabledSelectorBusinessDateView: Bool) {
        self.residenceCheckboxView.isHidden = !isEnableResidence
        if !isEnabledSelectorBusinessDateView {
            self.dateSelectorView.hidePeriodicEmissionDateField()
        }
    }
    
    public func setupPeriodicityModel(with model: SendMoneyPeriodicityViewModel) {
        self.dateSelectorView.setupPeriodicityModel(with: model.periodicityTypes)
    }
    
    public func updateInfo() {
        let transferTime = self.dateSelectorView.getTransferTime()
        self.presenter.updateInfo(ibanTransferView.text,
                                  nameText: self.recipientListTextField.text?.trim(),
                                  aliasText: self.aliasTextField.text?.trim(),
                                  transferTime: transferTime,
                                  isFavouriteSelected: saveContactCheckboxButton.isSelected)
        self.dateSelectorView.setDefaultValues(addingDays: self.presenter.differenceOfDaysToDeferredTransfers())
    }
    
    public func setDateTypeSaved(dateTypeModel: SendMoneyDateTypeFilledViewModel) {
        self.dateSelectorView.setDateTypeSaved(dateTypeModel: dateTypeModel)
    }
    
    public func disableEditingDestinationInformation() {
        self.recipientListTextField.addExtraAction(nil)
        self.recipientListTextField.hideArrowStyleImage()
        self.recipientListTextField.isUserInteractionEnabled = false
        self.ibanTransferView.isUserInteractionEnabled = false
    }
}

extension TransferDestinationViewController {
    public var associatedLoadingView: UIViewController {
        return self
    }
}

extension TransferDestinationViewController: LastBeneficiariesViewDelegate {
    func didTapInBeneficiary(_ viewModel: EmittedSepaTransferViewModel) {
        self.updateFavouriteInfo(viewModel.transferEmitted)
        self.presenter.validatableFieldChanged()
    }
}

extension TransferDestinationViewController: FavRecipientProtocol {
    func recipientSelected(_ viewModel: ContactListItemViewModel) {
        var name = viewModel.contact.payeeName
        if (name ?? "").isEmpty {
            name = viewModel.contact.payeeDisplayName
        }
        self.updateFavouriteInfo(name?.camelCasedString, iban: viewModel.contact.ibanRepresentable?.ibanString)
    }
}

extension TransferDestinationViewController: SendMoneyDateSelectorViewDelegate {
    public func didOpenSection(view: UIView) {
        self.scrollView.scrollRectToVisible(view.frame, animated: true)
    }
    
    public func dateDidBeginEditing() {
        self.action = .acceptAction
        self.keyboardManager.setDelegate(self)
        self.keyboardManager.setKeyboardButtonEnabled(true)
    }
}

extension TransferDestinationViewController: IbanCccTransferViewDelegate {
    func ibanDidBeginEditing() {
        self.setContinueToolbarAction()
    }
}

extension TransferDestinationViewController: UpdatableTextFieldDelegate {
    public func updatableTextFieldDidUpdate() {
        self.presenter.validatableFieldChanged()
    }
}

extension TransferDestinationViewController: KeyboardManagerDelegate {
    
    public var keyboardButton: KeyboardManager.ToolbarButton? {
        switch self.action {
        case .acceptAction:
            return KeyboardManager.ToolbarButton(
                title: localized("generic_button_accept"),
                accessibilityIdentifier: AccessibilityTransferDestination.transferDestinationBtnContinue.rawValue,
                action: { [weak self] _ in
                    self?.dateSelectorView.donePicker()
                },
                actionType: self.action
            )
        case .continueAction:
            return KeyboardManager.ToolbarButton(
                title: localized("generic_button_continue"),
                accessibilityIdentifier: AccessibilityTransferDestination.transferDestinationBtnContinue.rawValue,
                action: self.continueActionTextfield
            )
        }
    }
    
    public var associatedScrollView: UIScrollView? {
        return self.scrollView
    }
}

private extension TransferDestinationViewController {
    func changeCheckBoxButtonAccessibilityLabel() {
        if let state = self.saveContactCheckboxButton?.isSelected, state {
            self.saveContactCheckboxButton.accessibilityLabel = localized("voiceover_checkSaveContact_enable")
        } else {
            self.saveContactCheckboxButton.accessibilityLabel = localized("voiceover_checkSaveContact_disable")
        }
    }
}
