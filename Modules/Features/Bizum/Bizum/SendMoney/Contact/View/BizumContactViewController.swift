import UIKit
import UI
import Operative
import CoreFoundationLib
import ESUI

protocol BizumContactViewProtocol: OperativeView {
    var phoneString: String? { get }
    var arrayPhoneNumbers: [String] { get }
    func set(accountViewModel: SelectAccountHeaderViewModel)
    func addInputArea()
    func updateContinueAction(_ enable: Bool)
    func updateAcceptAction(_ enable: Bool)
    func setContantFrequents(contacts: [BizumFrequentViewModel])
    func setEmptyContactFrequents()
    func addContact(viewModel: BizumContactViewModel)
    func removeAllContacts()
    // TODO: Remove when not necessary anymore
    func showToast()
    func showAlertContactList()
    func showDialogPermission()
    func showContacts(with presenter: ContactListPresenter)
    func duplicatePhone()
    func showAddContactView()
}

final class BizumContactViewController: UIViewController {
    
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var selectedAccount: SelectAccountHeaderView!
    @IBOutlet private weak var stackView: UIStackView!
    @IBOutlet private var separator: UIView!
    @IBOutlet private var continueButton: WhiteLisboaButton! {
        didSet {
            self.continueButton.accessibilityIdentifier = AccessibilityOthers.btnContinue.rawValue
            self.continueButton.setTitle(localized("generic_button_continue"), for: .normal)
        }
    }
    @IBOutlet private var continueButtonView: UIView!
    let keyboardManager = KeyboardManager()
    let presenter: BizumContactPresenterProtocol
    private var inputStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8.0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    private let textField = LisboaMultiActionField()
    private lazy var labelInput: LisboaTwoLabelView = {
        let value = self.presenter.getHintContactValue()
        return LisboaTwoLabelView(leftLocalizedText: localized("*"), rightLocalizedText: localized(value))
    }()
    private lazy var bizumFrequentsView: OperativeBizumFrequentContactsView = {
        // Frequent contacts view
        let view = OperativeBizumFrequentContactsView(frame: .zero)
        view.delegate = self
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 220).isActive = true
        view.addLoadingView()
        return view
    }()
    private let labelButtonView = LisboaLabelButtonView()
    private var arrayContacts: [BizumContactViewModel] = []
    private let viewMargin = UIView()
    
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?,
         presenter: BizumContactPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.keyboardManager.setDelegate(self)
        self.setupView()
        self.presenter.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupNavigationBar()
        self.restoreProgressBar()
        self.presenter.viewWillAppear()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.operativeViewWillDisappear()
    }
}

private extension BizumContactViewController {
    func setupView() {
        self.selectedAccount.backgroundColor = .skyGray
        self.separator.backgroundColor = .mediumSkyGray
        self.continueButton.setTitle(localized("generic_button_continue"), for: .normal)
        self.continueButton.addSelectorAction(target: self, #selector(continueAction))
        self.setupTextField()
        self.setupAddLabelButtonView()
        self.labelInput.accessibilityIdentifier = AccessibilityBizumContact.bizumLabel
    }
    
    func setupNavigationBar() {
        let titleImage = TitleImage(
            image: ESAssets.image(named: "icnBizumHeader"),
            topMargin: 4,
            width: 16,
            height: 16
        )
        let builder = NavigationBarBuilder(
            style: .sky,
            title: .titleWithHeaderAndImage(
                titleKey: "toolbar_title_contact",
                header: .title(key: "toolbar_title_bizum", style: .default),
                image: titleImage
            )
        )
        builder.setRightActions(
            NavigationBarBuilder.RightAction.close(action: #selector(close))
        )
        builder.build(on: self, with: nil)
    }
    
    // MARK: - Components
    func setupTextField() {
        let phoneFormatter = PhoneTextFieldFormatter()
        self.textField.field.keyboardType = .phonePad
        self.textField.keyboardToolbar.doneBarButton.setTarget(self, action: #selector(self.dismissKeyboard))
        let contactView = ContactsView()
        let addContactView = AddContactView()
        let addContactComponent = ActionViewComponent(view: addContactView, type: .addContact) { [weak self] in
            guard let self = self else { return }
            self.acceptKeyboard()
        }
        let contactsComponent = ActionViewComponent(view: contactView, type: .contactList) { [weak self] in
            guard let self = self else { return }
            self.presenter.didSelectContacts()
        }
        self.textField.configure(with: phoneFormatter,
                                 title: localized("bizum_hint_mobileOrDirectory"),
                                 rightViews: [addContactComponent, contactsComponent])
        self.textField.updatableDelegate = self
        self.presenter.fields.append(self.textField)
        self.textField.accessibilityIdentifier = AccessibilityBizumContact.bizumInputSchedule
        self.textField.field.autocorrectionType = .no
    }
    
    func setupAddLabelButtonView() {
        self.labelButtonView.setViewModel(LisboaLabelButtonViewModel(title: localized("bizum_label_addRecipients")))
        self.labelButtonView.action = { [weak self] in
            self?.presenter.addNewContact()
        }
    }
    
    // MARK: - Common Actions
    @objc func dismissKeyboard() {
        self.textField.field.endEditing(true)
    }
    
    @objc func close() {
        self.presenter.didTapClose()
    }
    
    @objc func acceptKeyboard() {
        self.textField.endEditing(true)
        guard let phone = self.textField.field.text else { return }
        self.presenter.didSelectAcceptWithPhone(phone)
    }
    
    private func acceptKeyboardTextfield(_ textfield: EditText) {
        self.acceptKeyboard()
    }
    
    @objc func continueAction() {
        self.presenter.continueAction(contacts: self.arrayContacts)
    }
    
    func removeContact(identifier: String?) {
        guard let contact = self.arrayContacts.first(where: { $0.identifier == identifier }),
              let index = self.arrayContacts.firstIndex(of: contact),
              let tag = contact.tag,
              let viewToRemove = self.stackView.viewWithTag(tag) else { return }
        viewToRemove.removeFromSuperview()
        self.arrayContacts.remove(at: index)
        if self.arrayContacts.isEmpty {
            self.presenter.addNewContact()
        }
        self.presenter.removeContact(identifier: contact.identifier)
    }
    
    func showAlert(viewModel: BizumContactViewModel) {
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
    
    @objc func adjustButton() {
        self.navigateToSettings()
    }
}

extension BizumContactViewController: BizumContactViewProtocol {
    // TODO: Remove when not necessary anymore
    func showToast() {
        Toast.show("Próximamente")
    }
    
    var operativePresenter: OperativeStepPresenterProtocol {
        return presenter
    }
    
    var phoneString: String? {
        return self.textField.field.text
    }
    
    var arrayPhoneNumbers: [String] {
        return self.arrayContacts.map { $0.phone }
    }
    
    func set(accountViewModel: SelectAccountHeaderViewModel) {
        self.selectedAccount.setup(with: accountViewModel)
    }
    
    func updateContinueAction(_ enable: Bool) {
        self.continueButton.setIsEnabled(enable)
    }
    
    func updateAcceptAction(_ enable: Bool) {
        if !enable {
            textField.showError(localized("bizum_label_errorPhoneNumber"))
        }
    }
    
    // MARK: - Logic
    func addInputArea() {
        self.removeStackArea()
        self.inputStackView.addArrangedSubview(self.textField)
        self.inputStackView.addArrangedSubview(self.labelInput)
        self.stackView.addArrangedSubview(self.viewMargin)
        self.stackView.addArrangedSubview(self.bizumFrequentsView)
        // Constraints
        viewMargin.addSubview(self.inputStackView)
        viewMargin.trailingAnchor.constraint(equalTo: self.inputStackView.trailingAnchor, constant: 16.0).isActive = true
        viewMargin.leadingAnchor.constraint(equalTo: self.inputStackView.leadingAnchor, constant: -16.0).isActive = true
        viewMargin.topAnchor.constraint(equalTo: self.inputStackView.topAnchor).isActive = true
        viewMargin.bottomAnchor.constraint(equalTo: self.inputStackView.bottomAnchor).isActive = true
    }
    
    func setContantFrequents(contacts: [BizumFrequentViewModel]) {
        self.bizumFrequentsView.setViewModels(contacts)
    }
    
    func setEmptyContactFrequents() {
        self.bizumFrequentsView.showEmptyView()
    }
    
    func addContact(viewModel: BizumContactViewModel) {
        self.removeStackArea()
        self.addContactView(viewModel)
        self.arrayContacts.append(viewModel)
    }
    
    func removeAllContacts() {
        self.arrayContacts = []
        self.stackView.arrangedSubviews.forEach { view in
            guard let view = view as? BizumContactView else { return }
            view.removeFromSuperview()
        }
    }
    
    func duplicatePhone() {
        self.removeStackArea()
    }
    
    func removeStackArea() {
        self.textField.updateData(text: nil)
        self.labelButtonView.removeFromSuperview()
        self.bizumFrequentsView.removeFromSuperview()
        self.textField.removeFromSuperview()
        self.labelInput.removeFromSuperview()
        self.inputStackView.removeFromSuperview()
        self.viewMargin.removeFromSuperview()
    }
    
    func addContactView(_ viewModel: BizumContactViewModel) {
        let contactView = BizumContactView()
        contactView.setViewModel(viewModel)
        contactView.action = { [weak self] contactViewModel in
            guard let self = self else { return }
            self.showAlert(viewModel: contactViewModel)
        }
        self.stackView.addArrangedSubview(contactView)
    }
    
    func showAddContactView() {
        self.stackView.addArrangedSubview(self.labelButtonView)
    }
    
    // MARK: - Contact list
    func showAlertContactList() {
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
    
    func showDialogPermission() {
        let acceptComponents = DialogButtonComponents(titled: localized("genericAlert_buttom_settings"), does: adjustButton)
        let cancelComponents = DialogButtonComponents(titled: localized("generic_button_cancel"), does: nil)
        self.showOldDialog(title: nil, description: localized("onboarding_alert_text_permissionActivation"), acceptAction: acceptComponents, cancelAction: cancelComponents, isCloseOptionAvailable: false)
    }
    
    // MARK: - From contact list
    func showContacts(with presenter: ContactListPresenter) {
        let viewController = ContactListViewController(presenter: presenter)
        presenter.view = viewController
        viewController.modalPresentationStyle = .fullScreen
        self.present(viewController, animated: true)
    }
}

extension BizumContactViewController: KeyboardManagerDelegate {
    public var keyboardButton: KeyboardManager.ToolbarButton? {
        return KeyboardManager.ToolbarButton(title: localized("generic_button_accept"),
                                             accessibilityIdentifier: AccessibilityBizumContact.acceptButton,
                                             action: self.acceptKeyboardTextfield)
    }
    
    public var associatedScrollView: UIScrollView? {
        return self.scrollView
    }
}

extension BizumContactViewController: UpdatableTextFieldDelegate {
    func updatableTextFieldDidUpdate() {
        self.keyboardManager.setKeyboardButtonEnabled(true)
        guard let textfieldText = self.textField.text else { return }
        if !textfieldText.isEmpty {
            self.textField.switchRightViewTo(.addContact)
        } else {
            self.textField.switchRightViewTo(.contactList)
        }
    }
}

extension BizumContactViewController: OperativeBizumFrequentContactsViewDelegate {
    func didSelectFrequentContact(_ viewModel: BizumFrequentViewModel) {
        self.presenter.didSelectFrequentContacts(viewModel)
    }
}

extension BizumContactViewController: OldDialogViewPresentationCapable {}
extension BizumContactViewController: SystemSettingsNavigatable { }
