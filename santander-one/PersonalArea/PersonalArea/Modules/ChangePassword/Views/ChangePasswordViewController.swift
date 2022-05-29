import Operative
import UIKit
import UI
import CoreFoundationLib

protocol ChangePasswordViewProtocol: ValidatableFormViewProtocol, OperativeView {
    var textFields: [LisboaTextField] { get }
    func addLabel(_ text: String)
    func addTextField(viewModels: [ChangePasswordTextFieldViewModel])
    func showPasswordConfiguration(_ config: ChangePasswordConfiguration)
    func showErrorAlertView(_ message: LocalizedStylableText, positions: [Int])
    func showErrorUnderTexField(_ message: LocalizedStylableText, _ positions: [Int], identifier: String?)
    func setForcedAppareance()
}

extension ChangePasswordViewProtocol {
    func setForcedAppareance() {}
}

final class ChangePasswordViewController: UIViewController {
    let presenter: ChangePasswordPresenterProtocol
    let keyboardManager: KeyboardManager = KeyboardManager()
    var changePasswordConfiguration: ChangePasswordConfiguration?
    var textFields: [LisboaTextField] = []
    var lisboaErrorViews: [LisboaTextFieldWithErrorView] = []
    var shouldAllowSwipeBack = true
    @IBOutlet private weak var separatorView: UIView! {
        didSet {
            self.separatorView.backgroundColor = .mediumSkyGray
        }
    }
    @IBOutlet private weak var continueButton: WhiteLisboaButton! {
        didSet {
            self.continueButton.setIsEnabled(false)
            self.continueButton.setTitle(localized("displayOptions_button_saveChanges"), for: .normal)
            self.continueButton.accessibilityIdentifier = AccessibilityChangePassword.securityBtnSaveChanges
            self.continueButton.addSelectorAction(target: self, #selector(didSelectContinue))
        }
    }
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet weak var stackView: UIStackView!
    
    init(nibName nibNameOrNil: String?, presenter: ChangePasswordPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nibNameOrNil, bundle: .module)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupNavigationBar()
        self.presenter.viewWillAppear()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.keyboardManager.setDelegate(self)
        self.presenter.viewDidLoad()
        registerForKeyboardNotifications()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.keyboardManager.update()
    }

    func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShown(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillBeHidden(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil)
    }

    @objc func keyboardWillShown(_ notificiation: NSNotification) {
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = shouldAllowSwipeBack
    }

    @objc func keyboardWillBeHidden(_ notificiation: NSNotification) {
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = shouldAllowSwipeBack
    }
}

private extension ChangePasswordViewController {
    func setupNavigationBar() {
        let builder = NavigationBarBuilder(
            style: .sky,
            title: .title(key: "toolbar_title_keyChange")
        )
        builder.build(on: self, with: nil)
    }
    
    func createTextFieldWithId(_ identifier: String?, placeHolder: String) -> UIView? {
        let lisboaTextFieldErrorView = LisboaTextFieldWithErrorView()
        guard let passwordTextField = lisboaTextFieldErrorView.textField else { return nil }
        lisboaTextFieldErrorView.accessibilityIdentifier = identifier
        lisboaTextFieldErrorView.setHeight(48.0)
        passwordTextField.setEditingStyle(
            .writable(configuration: LisboaTextField.WritableTextField(
                        type: .floatingTitle,
                        formatter: SecureTextFieldFormatter(maxLength: self.changePasswordConfiguration?.maxLength, customTextValidatorDelegate: presenter.getCustomTextValidatorProtocol()),
                        disabledActions: [],
                        keyboardReturnAction: nil,
                        textfieldCustomizationBlock: self.setupTextField)))
        passwordTextField.placeholder = localized(placeHolder)
        let rightAccessoryId = "\(identifier ?? "")"
        passwordTextField.setRightAccessory(.secure("icnEyeOpenPass", "icnEyeClosePass"), identifier: rightAccessoryId)
        passwordTextField.updatableDelegate = self
        passwordTextField.accessibilityIdentifier = "\(identifier ?? "")_textField"
        self.presenter.fields.append(passwordTextField)
        self.textFields.append(passwordTextField)
        self.lisboaErrorViews.append(lisboaTextFieldErrorView)
        return lisboaTextFieldErrorView
    }
    
    func setupTextField(_ component: LisboaTextField.CustomizableComponents) {
        component.textField.keyboardType = self.changePasswordConfiguration?.keyboardType ?? .default
    }
    
    @objc func didSelectContinue() {
        self.presenter.didSelectContinue()
    }
    
    func didSelectContinueTextfield(_ textfield: EditText) {
        self.didSelectContinue()
    }
}

extension ChangePasswordViewController: ChangePasswordViewProtocol {
    var operativePresenter: OperativeStepPresenterProtocol {
        return presenter
    }
    
    func updateContinueAction(_ enable: Bool) {
        self.continueButton.setIsEnabled(enable)
        self.keyboardManager.setKeyboardButtonEnabled(enable)
    }
    
    func addLabel(_ text: String) {
        let identifier = AccessibilityChangePassword.keyChangeTextAbout
        let view = LisboaLabelView(text: localized(text),
                                   textAlignment: .left,
                                   font: .santander(family: .text, type: .regular, size: 16.0),
                                   topMargin: 18.0,
                                   bottomMargin: 14.0,
                                   leftMargin: 0.0,
                                   rightMargin: 0.0,
                                   identifier: identifier)
        view.accessibilityIdentifier = AccessibilityChangePassword.keyChangeTextAboutBox
        self.stackView.addArrangedSubview(view)
    }
    
    func addTextField(viewModels: [ChangePasswordTextFieldViewModel]) {
        let views = viewModels.compactMap { self.createTextFieldWithId($0.identifier, placeHolder: $0.placeHolder) }
        views.forEach(self.stackView.addArrangedSubview)
    }
    
    func showPasswordConfiguration(_ config: ChangePasswordConfiguration) {
        self.changePasswordConfiguration = config
    }
    
    func showErrorAlertView(_ message: LocalizedStylableText, positions: [Int]) {
        positions.forEach { position in
            self.lisboaErrorViews[position].showError(nil)
        }
        TopAlertController.setup(TopAlertView.self).showAlert(message, alertType: .failure, position: .bottom)
    }
    
    func showErrorUnderTexField(_ message: LocalizedStylableText, _ positions: [Int], identifier: String? = nil) {
        positions.forEach { position in
            self.lisboaErrorViews[position].showError(message.text)
            self.lisboaErrorViews[position].accessibilityIdentifier = identifier
        }
    }
    
    func hideErrors() {
        self.lisboaErrorViews.forEach { view in
            view.hideError()
        }
    }

    func setForcedAppareance() {
        shouldAllowSwipeBack = false
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = shouldAllowSwipeBack
    }
}

extension ChangePasswordViewController: UpdatableTextFieldDelegate {
    func updatableTextFieldDidUpdate() {
        self.hideErrors()
        self.presenter.validatableFieldChanged()
    }
}

extension ChangePasswordViewController: KeyboardManagerDelegate {
    var keyboardButton: KeyboardManager.ToolbarButton? {
        return KeyboardManager.ToolbarButton(
            title: localized("generic_button_continue"),
            accessibilityIdentifier: "generic_button_continue",
            action: self.didSelectContinueTextfield,
            actionType: .continueAction
        )
    }
    
    var associatedView: UIView {
        return self.scrollView
    }
}
