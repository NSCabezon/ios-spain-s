//
//  BizumSplitExpensesAmountViewController.swift
//  Bizum

import UIKit
import UI
import CoreFoundationLib
import Operative
import ESUI

protocol BizumSplitExpensesAmountViewProtocol: ValidatableFormViewProtocol, OperativeView, BizumAmountMultimediaViewProtocol, PhotoHelperDelegate {
    var phoneString: String? { get }
    var phoneNumbersArray: [String] { get }
    func showBizumNonRegistered(onAccept: @escaping () -> Void, onCancel: (() -> Void)?)
    func showNotSplittableError()
    func showAmountError(_ error: String)
    func hideAmountError()
    func showErrorMessage(key: String)
    func showTransaction(_ viewModel: SplitTransactionViewModel)
    // Contacts related
    func removeAllContacts()
    func addContactsInputArea()
    func setEmptyFrequentContacts()
    func setFrequentContacts(contacts: [BizumFrequentViewModel])
    func addContact(viewModel: SplitTransactionContactViewModel)
    func showAddMoreContactsView()
    func duplicatePhone()
    func reloadSplittedAmountBetweenContacts(ownAmount: AmountEntity, remainingContactsAmount: AmountEntity)
    func updateAcceptAction(_ enable: Bool)
    // Contacts phone book
    func showPhoneBookAccessPermissionDialog()
    func showPhoneBookAccessAlert()
    func showPhoneBook(with presenter: ContactListPresenter)
}

final class BizumSplitExpensesAmountViewController: UIViewController {
    let presenter: BizumSplitExpensesAmountPresenterProtocol
    let keyboardManager: KeyboardManager = KeyboardManager()
    var associatedScrollView: UIScrollView? { return self.scrollView }
    var phoneString: String? {
        return self.phoneTextField.field.text
    }
    var phoneNumbersArray: [String] {
        return self.arrayContacts.map { $0.phone }
    }
    private var sendMoneyView: UIView?
    private var sendMoneyViewProtocol: SendingInformationBizumDelegate?
    private var arrayContacts: [SplitTransactionContactViewModel] = []
    private var contactsStackView: UIStackView = {
        // This stackView contains all the contact related elements
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 0.0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    private lazy var bizumFrequentContactsView: OperativeBizumFrequentContactsView = {
        // Frequent contacts view
        let view = OperativeBizumFrequentContactsView(frame: .zero)
        view.delegate = self
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 220).isActive = true
        view.accessibilityIdentifier = AccessibilityBizumSplitExpenses.amountListFrequentContacts
        view.addLoadingView()
        return view
    }()
    private var inputStackView: UIStackView = {  
        // Manual phone input and phone book button
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 0.0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    private let phoneTextField = LisboaMultiActionField()
    private var labelInput: LisboaTwoLabelView = {
        let view =  LisboaTwoLabelView(leftLocalizedText: localized("*"), rightLocalizedText: localized("bizum_tooltip_writeAMobileNumberRequest"))
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private let viewMargin = UIView()
    private let inputStackSpacingView = UIView()
    private let addMoreContactsButtonView = LisboaLabelButtonView()

    @IBOutlet weak var footerContainerView: UIView!
    @IBOutlet private weak var separatorView: UIView! {
        didSet {
            self.separatorView.backgroundColor = .mediumSkyGray
        }
    }
    @IBOutlet private weak var continueButton: WhiteLisboaButton! {
        didSet {
            self.continueButton.setIsEnabled(false)
            self.continueButton.setTitle(localized("generic_button_continue"), for: .normal)
            self.continueButton.accessibilityIdentifier = AccessibilityBizumSendMoney.bizumBtnContinue
            self.continueButton.addSelectorAction(target: self, #selector(didSelectContinue))
        }
    }
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet weak var stackView: UIStackView!
    private lazy var conceptTextField: LisboaTextField = {
        let conceptFormatter = UIFormattedCustomTextField()
        conceptFormatter.setMaxLength(maxLength: 35)
        conceptFormatter.setAllowOnlyCharacters(.bizumConcept)
        let textField = LisboaTextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.setEditingStyle(.writable(configuration: LisboaTextField.WritableTextField(type: .floatingTitle, formatter: conceptFormatter)))
        textField.placeholder = localized("bizum_hint_concept")
        textField.heightAnchor.constraint(equalToConstant: 52).isActive = true
        textField.updatableDelegate = self
        textField.accessibilityIdentifier = AccessibilityBizumSplitExpenses.amountConceptInput
        textField.setClearAccessory(.clearDefault)
        return textField
    }()
    private lazy var headerView: SplitTransactionHeaderView = {
        let view = SplitTransactionHeaderView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    init(nibName nibNameOrNil: String?, presenter: BizumSplitExpensesAmountPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nibNameOrNil, bundle: .module)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureView()
        self.setupNavigationBar()
        self.presenter.viewDidLoad()
        self.keyboardManager.setDelegate(self)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.keyboardManager.update()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.operativeViewWillDisappear()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.presenter.viewWillAppear()
    }

    @objc func openSettings() {
         self.navigateToSettings()
    }
}

extension BizumSplitExpensesAmountViewController: UpdatableTextFieldDelegate {
    func updatableTextFieldDidUpdate() {
        // Concept
        self.presenter.conceptUpdated(self.conceptTextField.text ?? "")
        // Phone input
        self.keyboardManager.setKeyboardButtonEnabled(true)
        guard let textfieldText = self.phoneTextField.text else { return }
        if !textfieldText.isEmpty {
            self.phoneTextField.switchRightViewTo(.addContact)
        } else {
            self.phoneTextField.switchRightViewTo(.contactList)
        }
    }
    
    func updateAcceptAction(_ enable: Bool) {
        if !enable {
            self.phoneTextField.showError(localized("bizum_label_errorPhoneNumber"))
        }
    }
}

extension BizumSplitExpensesAmountViewController: BizumSplitExpensesAmountViewProtocol {
    
    // MARK: - General
    var viewForPresentation: UIViewController? {
        return self
    }
    
    func selectedImage(image: Data) {
        self.presenter.selectedImage(image: image)
    }
    
    func showError(error: PhotoHelperError) {
        let keyDesc: String
        switch error {
        case .noPermissionCamera:
            keyDesc = "permissionsAlert_text_camera"
        case .noPermissionPhotoLibrary:
            keyDesc = "permissionsAlert_text_photos"
        }
        self.showRequestGalleryAccess(keyDesc)
    }
    
    var operativePresenter: OperativeStepPresenterProtocol {
        return presenter
    }

    func updateContinueAction(_ enable: Bool) {
        self.continueButton.setIsEnabled(enable)
        self.keyboardManager.setKeyboardButtonEnabled(enable)
    }

    func showBizumNonRegistered(onAccept: @escaping () -> Void, onCancel: (() -> Void)?) {
        let absoluteMargin: (left: CGFloat, right: CGFloat) = (left: 19.0, right: 9.0)
        let components: [LisboaDialogItem] = [
            .margin(36.0),
            .styledText(LisboaDialogTextItem(text: localized("bizum_alert_weCantNot"),
                                             font: .santander(family: .text, type: .regular, size: 22),
                                             color: .lisboaGray,
                                             alignament: .center,
                                             margins: absoluteMargin)),
            .margin(16.0),
            .styledText(LisboaDialogTextItem(text: localized("bizum_alert_notRegistered"),
                                             font: .santander(family: .text, type: .regular, size: 16),
                                             color: .lisboaGray,
                                             alignament: .center,
                                             margins: absoluteMargin)),
            .margin(22.0),
            .horizontalActions(HorizontalLisboaDialogActions(left: LisboaDialogAction(title: localized("generic_button_cancel"),
                                                                                      type: .white,
                                                                                      margins: absoluteMargin,
                                                                                      isCancelAction: true,
                                                                                      action: onCancel ?? {  }),
                                                             right: LisboaDialogAction(title: localized("generic_button_accept"),
                                                                                       type: .red,
                                                                                       margins: absoluteMargin,
                                                                                       action: onAccept))),
            .margin(24.0)
        ]

        let builder = LisboaDialog(items: components, closeButtonAvailable: false)
        builder.showIn(self)
    }
    
    func showNotSplittableError() {
        LisboaDialog(
            items: [
                .margin(36),
                .styledText(LisboaDialogTextItem(text: localized("bizum_alert_divide"), font: .santander(size: 22), color: .lisboaGray, alignament: .center, margins: (25, 25))),
                .margin(20),
                .styledText(LisboaDialogTextItem(text: localized("bizum_alert_addMore"), font: .santander(size: 16), color: .lisboaGray, alignament: .center, margins: (42, 42))),
                .margin(35),
                .verticalAction(VerticalLisboaDialogAction(title: localized("generic_button_accept"), type: .red, margins: (left: 16.0, right: 8.0), action: {})),
                .margin(21)
            ],
            closeButtonAvailable: false
        ).showIn(self)
    }

    func showErrorMessage(key: String) {
        self.showOldDialog(
             title: nil,
             description: localized(key),
             acceptAction: DialogButtonComponents(titled: localized("generic_button_accept"), does: nil),
             cancelAction: nil,
             isCloseOptionAvailable: false
         )
     }

    func showAmountError(_ error: String) {
        self.sendMoneyViewProtocol?.showAmountError(error)
    }

    func hideAmountError() {
        self.sendMoneyViewProtocol?.hideAmountError()
    }
    
    func showTransaction(_ viewModel: SplitTransactionViewModel) {
        self.headerView.update(with: viewModel)
    }
    
    // MARK: - Contacts
    func setupContactsView() {
        self.setupPhoneTextField()
        self.setupAddLabelButtonView()
        self.labelInput.accessibilityIdentifier = AccessibilityBizumContact.bizumLabel
    }
    
    func setupPhoneTextField() {
        let phoneFormatter = PhoneTextFieldFormatter()
        self.phoneTextField.field.keyboardType = .phonePad
        self.phoneTextField.keyboardToolbar.doneBarButton.setTarget(self, action: #selector(self.dismissKeyboard))
        let contactView = ContactsView()
        let addContactView = AddContactView()
        let addContactComponent = ActionViewComponent(view: addContactView, type: .addContact) { [weak self] in
            guard let self = self else { return }
            self.acceptKeyboard()
        }
        let contactsComponent = ActionViewComponent(view: contactView, type: .contactList) { [weak self] in
            guard let self = self else { return }
            self.presenter.didSelectPhoneBook()
        }
        self.phoneTextField.configure(with: phoneFormatter,
                                 title: localized("bizum_hint_mobileOrDirectory"),
                                 rightViews: [addContactComponent, contactsComponent])
        self.phoneTextField.updatableDelegate = self
        self.phoneTextField.accessibilityIdentifier = AccessibilityBizumSplitExpenses.amountAddPhoneInput
        self.phoneTextField.field.autocorrectionType = .no
        self.phoneTextField.field.clearButtonMode = .whileEditing
    }
    
    func setupAddLabelButtonView() {
        self.addMoreContactsButtonView.setViewModel(LisboaLabelButtonViewModel(title: localized("bizum_label_addRecipients")))
        self.addMoreContactsButtonView.action = { [weak self] in
            self?.presenter.didSelectAddMoreContacts()
        }
    }
    
    // Manage contact input field
    @objc func dismissKeyboard() {
        self.phoneTextField.field.endEditing(true)
    }
    @objc func acceptKeyboard() {
        self.phoneTextField.endEditing(true)
        guard let phone = self.phoneTextField.field.text else { return }
        self.presenter.didSelectAcceptWithPhone(phone)
    }
    
    // Actions
    func showAddMoreContactsView() {
        let view = UIView()
        view.backgroundColor = .white
        view.addSubview(self.addMoreContactsButtonView)
        self.addMoreContactsButtonView.fullFit(topMargin: 8, bottomMargin: 8, leftMargin: 0, rightMargin: 0)
        self.contactsStackView.addArrangedSubview(view)
    }
    
    func addContact(viewModel: SplitTransactionContactViewModel) {
        self.removeStackArea()
        self.addContactView(viewModel)
        self.arrayContacts.append(viewModel)
        if self.arrayContacts.count > 1 {
            self.updateMeAvatarConstraintLeadingSpace()
        }
    }
    
    func removeAllContacts() {
        self.arrayContacts = []
        self.contactsStackView.arrangedSubviews.forEach { view in
            guard let view = view as? SplitTransactionContactView else { return }
            view.removeFromSuperview()
        }
    }
    
    func removeContact(identifier: String?) {
        guard let contact = self.arrayContacts.first(where: { $0.identifier == identifier }),
              let index = self.arrayContacts.firstIndex(of: contact),
              let tag = contact.tag,
              let viewToRemove = self.stackView.viewWithTag(tag) else { return }
        viewToRemove.removeFromSuperview()
        self.arrayContacts.remove(at: index)
        if self.arrayContacts.isEmpty {
            self.presenter.didSelectAddMoreContacts()
        }
        self.presenter.removeContact(identifier: contact.identifier)
        if self.arrayContacts.count == 1 {
            self.updateMeAvatarConstraintToZero()
        }
    }
    
    func updateMeAvatarConstraintToZero() {
        self.contactsStackView.arrangedSubviews.forEach { view in
            guard let view = view as? SplitTransactionContactView,
                  let viewModel = view.getViewModel(),
                  viewModel.tag == 0 else { return }
            view.setAvatarConstraintToZero()
        }
    }
    
    func updateMeAvatarConstraintLeadingSpace() {
        self.contactsStackView.arrangedSubviews.forEach { view in
            guard let view = view as? SplitTransactionContactView,
                  let viewModel = view.getViewModel(),
                  viewModel.tag == 0 else { return }
            view.setAvatarConstraintLeadingSpace()
        }
    }
    
    func reloadSplittedAmountBetweenContacts(ownAmount: AmountEntity, remainingContactsAmount: AmountEntity) {
        self.contactsStackView.arrangedSubviews.forEach({
            if let view = $0 as? SplitTransactionContactView, let contactModel = view.getViewModel() {
                let newAmount = (contactModel.isDeviceUser) ? ownAmount : remainingContactsAmount
                var updatedContactModel = contactModel
                updatedContactModel.updateSplittedAmount(newAmount)
                if contactModel.identifier == arrayContacts.last?.identifier {
                    updatedContactModel.showPlainSeparator()
                } else {
                    updatedContactModel.showDottedSeparator()
                }
                view.update(with: updatedContactModel)
            }
        })
    }
    
    func addContactsInputArea() {
        self.removeStackArea()
        self.inputStackSpacingView.heightAnchor.constraint(equalToConstant: 10).isActive = true
        self.inputStackView.addArrangedSubview(self.inputStackSpacingView)
        self.inputStackView.addArrangedSubview(self.phoneTextField)
        self.inputStackView.addArrangedSubview(self.labelInput)
        self.contactsStackView.addArrangedSubview(self.viewMargin)
        self.contactsStackView.addArrangedSubview(self.bizumFrequentContactsView)
        // Constraints
        self.viewMargin.addSubview(self.inputStackView)
        self.viewMargin.trailingAnchor.constraint(equalTo: self.inputStackView.trailingAnchor, constant: 16.0).isActive = true
        self.viewMargin.leadingAnchor.constraint(equalTo: self.inputStackView.leadingAnchor, constant: -16.0).isActive = true
        self.viewMargin.topAnchor.constraint(equalTo: self.inputStackView.topAnchor).isActive = true
        self.viewMargin.bottomAnchor.constraint(equalTo: self.inputStackView.bottomAnchor).isActive = true
    }
    
    func setEmptyFrequentContacts() {
       self.bizumFrequentContactsView.showEmptyView()
    }
    
    func setFrequentContacts(contacts: [BizumFrequentViewModel]) {
        self.bizumFrequentContactsView.setViewModels(contacts)
    }
    
    func removeStackArea() {
        self.phoneTextField.updateData(text: nil)
        self.addMoreContactsButtonView.removeFromSuperview()
        self.bizumFrequentContactsView.removeFromSuperview()
        self.phoneTextField.removeFromSuperview()
        self.labelInput.removeFromSuperview()
        self.inputStackView.removeFromSuperview()
        self.viewMargin.removeFromSuperview()
        self.inputStackSpacingView.removeFromSuperview()
    }
    
    func addContactView(_ viewModel: SplitTransactionContactViewModel) {
        let contactView = SplitTransactionContactView()
        contactView.setViewModel(viewModel)
        contactView.action = { [weak self] contactViewModel in
            guard let self = self else { return }
            self.showAlert(viewModel: contactViewModel)
        }
        if self.arrayContacts.count == 0 {
            contactView.setAvatarConstraintToZero()
        }
        self.contactsStackView.addArrangedSubview(contactView)
    }
    
    func showAlert(viewModel: SplitTransactionContactViewModel) {
        let acceptAction = LisboaDialogAction(title: localized("generic_button_accept"), type: .red, margins: (left: 16.0, right: 8.0)) {
            self.removeContact(identifier: viewModel.identifier)
            self.presenter.trackRemoveContact()
        }
        let cancelAction = LisboaDialogAction(title: localized("generic_button_cancel"), type: .white, margins: (left: 16.0, right: 8.0)) { }
        LisboaDialog(
            items: [
                .margin(36),
                .styledText(LisboaDialogTextItem(text: localized("bizum_alert_delete"), font: .santander(size: 22), color: .lisboaGray, alignament: .center, margins: (25, 25))),
                .margin(20),
                .styledText(LisboaDialogTextItem(text: localized("bizum_alert_sure"), font: .santander(size: 16), color: .lisboaGray, alignament: .center, margins: (42, 42))),
                .margin(35),
                .horizontalActions(HorizontalLisboaDialogActions(left: cancelAction, right: acceptAction)),
                .margin(16)
            ],
            closeButtonAvailable: false
        ).showIn(self)
    }
    
    func duplicatePhone() {
        self.removeStackArea()
    }
    
    // MARK: - Phone Book
    func showPhoneBookAccessAlert() {
        let allowAction = LisboaDialogAction(title: localized("generic_button_allow"), type: .red, margins: (left: 16.0, right: 8.0)) {
            self.presenter.didAllowPermission()
        }
        let refuseAction = LisboaDialogAction(title: localized("generic_button_toRefuse"), type: .white, margins: (left: 16.0, right: 8.0)) { }
        LisboaDialog(
            items: [
                .margin(19.0),
                .image(LisboaDialogImageViewItem(image: ESAssets.image(named: "icnBizumContacts48"), size: (width: 56, height: 64))),
                .margin(6.0),
                .styledText(LisboaDialogTextItem(text: localized("bizum_alert_accessContactBook"), font: .santander(size: 29), color: .lisboaGray, alignament: .center, margins: (25, 25))),
                .margin(13.0),
                .styledText(LisboaDialogTextItem(text: localized("bizum_alert_appPermission"), font: .santander(family: .text, type: .light, size: 16.0), color: .lisboaGray, alignament: .center, margins: (16, 16))),
                .margin(30),
                .horizontalActions(HorizontalLisboaDialogActions(left: refuseAction, right: allowAction)),
                .margin(6)
            ],
            closeButtonAvailable: false
        ).showIn(self)
    }
    
    func showPhoneBookAccessPermissionDialog() {
        let acceptComponents = DialogButtonComponents(titled: localized("genericAlert_buttom_settings"), does: adjustButton)
        let cancelComponents = DialogButtonComponents(titled: localized("generic_button_cancel"), does: nil)
        self.showOldDialog(title: nil, description: localized("onboarding_alert_text_permissionActivation"), acceptAction: acceptComponents, cancelAction: cancelComponents, isCloseOptionAvailable: false)
    }
    
    func showPhoneBook(with presenter: ContactListPresenter) {
        let viewController = ContactListViewController(presenter: presenter)
        presenter.view = viewController
        viewController.modalPresentationStyle = .fullScreen
        self.present(viewController, animated: true)
    }
}

private extension BizumSplitExpensesAmountViewController {
    func configureView() {
        self.stackView.addArrangedSubview(self.headerView)
        self.stackView.addArrangedSubview(self.contactsStackView)
        self.addContactsToConceptSeparatorView()
        self.addConcept()
        self.setupContactsView()
        self.scrollView.delegate = self
        self.footerContainerView.addShadow(location: .bottom, color: .clear, opacity: 0.7, height: 0.5)
    }
    
    func addContactsToConceptSeparatorView() {
        let view = UIView()
        view.backgroundColor = .white
        let plainSeparatorView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: self.stackView.frame.size.width, height: 1.0))
        plainSeparatorView.backgroundColor = UIColor.mediumSkyGray
        plainSeparatorView.heightAnchor.constraint(equalToConstant: 1.0).isActive = true
        view.addSubview(plainSeparatorView)
        plainSeparatorView.fullFit(topMargin: 0, bottomMargin: 0, leftMargin: 15, rightMargin: 15)
        self.stackView.addArrangedSubview(view)
    }
    
    func addConcept() {
        let view = UIView()
        view.backgroundColor = .white
        view.addSubview(self.conceptTextField)
        self.conceptTextField.fullFit(topMargin: 17, bottomMargin: 17, leftMargin: 15, rightMargin: 15)
        self.stackView.addArrangedSubview(view)
    }

    func setupNavigationBar() {
        let titleImage = TitleImage(image: ESAssets.image(named: "icnBizumHeader"),
                                    topMargin: 4,
                                    width: 16,
                                    height: 16)
        let builder = NavigationBarBuilder(
            style: .sky,
            title: .titleWithHeaderAndImage(titleKey: "toolbar_title_contact",
                                            header: .title(key: "toolbar_title_bizum", style: .default),
                                            image: titleImage)
        )
        builder.setRightActions(
            NavigationBarBuilder.RightAction.close(action: #selector(close))
        )
        builder.build(on: self, with: nil)
    }
    
    @objc func didSelectContinue() {
        self.presenter.didSelectContinue()
    }

    @objc func close() {
        self.presenter.didTapClose()
    }
    
    @objc func adjustButton() {
        self.navigateToSettings()
    }
}

// MARK: - Other extensions
extension BizumSplitExpensesAmountViewController: BizumUpdatableSendingMoneyDelegate {
    func updateSendingAmount(_ amount: Decimal) {
        self.hideAmountError()
    }
}

extension BizumSplitExpensesAmountViewController: GenericErrorDialogPresentationCapable {
    var associatedGenericErrorDialogView: UIViewController {
        return self
    }
}

extension BizumSplitExpensesAmountViewController: OperativeBizumFrequentContactsViewDelegate {
    func didSelectFrequentContact(_ viewModel: BizumFrequentViewModel) {
        self.presenter.didSelectFrequentContacts(viewModel)
    }
}

extension BizumSplitExpensesAmountViewController: UITextFieldDelegate {}

extension BizumSplitExpensesAmountViewController: KeyboardManagerDelegate {
    var keyboardButton: KeyboardManager.ToolbarButton? {
        return KeyboardManager.ToolbarButton(title: localized("generic_button_continue"),
                                             accessibilityIdentifier: "",
                                             action: { [weak self] _  in
                                                self?.didSelectContinue()
                                             },
                                             actionType: .continueAction)
    }

    var associatedView: UIView {
        return self.scrollView
    }
}

extension BizumSplitExpensesAmountViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.footerContainerView.layer.shadowColor =
            scrollView.contentOffset.y > 0.0 ? UIColor.black.withAlphaComponent(0.7).cgColor : UIColor.clear.cgColor
    }
}
