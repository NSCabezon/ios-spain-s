//
//  UnrememberedLoginView.swift
//  Pods
//
//  Created by Juan Carlos López Robles on 11/20/20.
//

import Foundation
import UI
import UIKit
import CoreFoundationLib
import IQKeyboardManagerSwift
import ESCommons
import Ecommerce

typealias LoginViewCapable = LoadingLoginViewCapable &
    ShowLoginErrorViewCapable & ChangeEnvironmentViewCapable

protocol UnrememberedLoginViewProtocol: class, LoginViewCapable {
    func resetPassword()
    func resetForm()
}

public class UnrememberedLoginViewController: UIViewController {
    private let presenter: UnrememberedLoginPresenterProtocol
    let dependenciesResolver: DependenciesResolver
    @IBOutlet weak var environmentButton: UIButton?
    @IBOutlet weak var backgroundImageView: UIImageView?
    @IBOutlet weak var sanIconImageView: UIImageView?
    @IBOutlet weak var regardLabel: UILabel?
    @IBOutlet weak var documentTextField: DocumentTextField?
    @IBOutlet weak var passwordTextField: PasswordTextField?
    @IBOutlet weak var rememberMeView: RememberMeView?
    @IBOutlet weak var loginButton: UIButton?
    @IBOutlet weak var restoreButton: ResponsiveStateButton?
    @IBOutlet weak var bottonDistance: NSLayoutConstraint?
    private var loginDropDownView = LoginDropDownView()
    private lazy var keyboardDismisser: KeyboardDismisser? = {
        guard isKeyboardDismisserAllowed() else {
            return nil
        }
        return KeyboardDismisser(viewController: self)
    }()
    
    public override var shouldAutorotate: Bool {
        return true
    }
    
    init(nibName: String?, bundle: Bundle?,
         dependenciesResolver: DependenciesResolver,
         presenter: UnrememberedLoginPresenterProtocol) {
        self.dependenciesResolver = dependenciesResolver
        self.presenter = presenter
        super.init(nibName: nibName, bundle: bundle)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.presenter.viewDidLoad()
        self.setupEnvironmentButton()
        self.setupViews()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.addKeyboardObserver()
        self.presenter.viewWillAppear()
        self.setnavigationBar()
        self.keyboardDismisser?.start()
        self.forceOrientationForPresentation()
        checkDemoLogin()
    }
    
    func setnavigationBar() {
        NavigationBarBuilder(style: .clear(tintColor: .white), title: .none)
            .setRightActions(.menu(action: #selector(didSelectMenu)))
            .build(on: self, with: nil)
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.removeKeyboardObserver()
        self.presenter.viewWillDisappear()
        self.keyboardDismisser?.stop()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.configureDropDownView()
        self.presenter.viewDidAppear()
        self.enableUserInteraction()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBAction func didSelectChooseEnvironment(_ sender: Any) {
        self.chooseEnvironment()
    }
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @objc func didSelectMenu() {
        presenter.didSelectMenu()
    }
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        if touch?.view == self.view {
            if self.loginDropDownView.getIsDropDownPresent() {
                self.dropDownButtonDidPressed()
            }
            self.view.endEditing(true)
        }
    }

    func enableUserInteraction() {
        self.view.isUserInteractionEnabled = true
    }
}

extension UnrememberedLoginViewController: UnrememberedLoginViewProtocol {
    func resetPassword() {
        self.passwordTextField?.reset()
    }
    
    func resetForm() {
        self.passwordTextField?.reset()
        self.documentTextField?.setText("")
        self.enableUserInteraction()
    }
    
    public func shakeWasOccurred() {
        self.presenter.didShakeWasOccurred()
    }
    
    func chooseEnvironment() {
        self.presenter.didSelectChooseEnvironment()
    }
    
    func didUpdateEnvironments() {
        IQKeyboardManager.shared.enableAutoToolbar = false
    }
}

extension UnrememberedLoginViewController: PasswordTextFieldDelegate {
    public func enterDidPressed() {
        self.loginButtonDidPressed()
    }
}

private extension UnrememberedLoginViewController {
    func isKeyboardDismisserAllowed() -> Bool {
        return parent == nil || parent is UINavigationController
    }
    
    func setupViews() {
        IQKeyboardManager.shared.enableAutoToolbar = false
        commonInit()
    }
    
    func commonInit() {
        sanIconImageView?.image = Assets.image(named: "icnSanWhiteLisboa")
        configureRegardLabel()
        configureBackground()
        configureTextFields()
        configureButtons()
        setAccessibility()
    }
    
    func configureRegardLabel() {
        regardLabel?.font = .santander(family: .text, type: .light, size: 40)
        regardLabel?.textColor = UIColor.Legacy.uiWhite
        regardLabel?.text = regardNow()
    }
    
    func configureBackground() {
        backgroundImageView?.image = TimeImageAndGreetingViewModel().backgroundImage
        backgroundImageView?.contentMode = .scaleAspectFill
    }
    
    func configureTextFields() {
        documentTextField?.setPlaceholder(localized("login_hint_documentNumber").text)
        documentTextField?.setReturnAction { [weak self] in self?.passwordTextField?.becomeResponder() }
        documentTextField?.docTextDelegate = self
        passwordTextField?.setPlaceholder(localized("login_hint_password").text)
        passwordTextField?.delegate = self
    }
    
    func configureButtons() {
        rememberMeView?.setTitle(localized("login_radioButton_rememberUser").text)
        loginButton?.set(localizedStylableText: localized("login_button_enter"), state: .normal)
        loginButton?.setTitleColor(UIColor.Legacy.uiWhite, for: .normal)
        loginButton?.backgroundColor = UIColor.santanderRed
        loginButton?.layer.cornerRadius = (loginButton?.frame.height ?? 0.0) / 2.0
        loginButton?.titleLabel?.font = UIFont.santander(family: .text, type: .bold, size: 18.0)
        loginButton?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(loginButtonDidPressed)))
        
        restoreButton?.backgroundColor = UIColor.clear
        restoreButton?.setTitle(localized("login_button_lostKey").text, for: .normal)
        restoreButton?.titleLabel?.font = UIFont.santander(family: .text, type: .regular, size: 14)
        restoreButton?.titleLabel?.textColor = UIColor.Legacy.uiWhite
        restoreButton?.onTouchAction = { [weak self] _ in
            self?.presenter.recoverUserPassword()
        }
    }
    
    func configureDropDownView() {
        self.view.addSubview(loginDropDownView)
        view.bringSubviewToFront(loginDropDownView)
        guard let documentTextField = documentTextField else { return }
        loginDropDownView.setUpDropDown(viewPositionReference: view.convert(documentTextField.frame, from: documentTextField))
        loginDropDownView.delegate = self
    }
    
    func setAccessibility() {
        environmentButton?.accessibilityIdentifier = AccessibilityUnrememberedLogin.btnEnvironment.rawValue
        environmentButton?.titleLabel?.accessibilityIdentifier = AccessibilityUnrememberedLogin.btnEnvironmentLabel.rawValue
        backgroundImageView?.accessibilityIdentifier = AccessibilityUnrememberedLogin.backgroundImageView.rawValue
        sanIconImageView?.accessibilityIdentifier = AccessibilityUnrememberedLogin.sanIconImageView.rawValue
        regardLabel?.accessibilityIdentifier = AccessibilityUnrememberedLogin.regardLabel.rawValue
        documentTextField?.accessibilityIdentifier = AccessibilityUnrememberedLogin.inputTextDocument.rawValue
        documentTextField?.loginTypeLabel.accessibilityIdentifier = presenter.getLoginTypeIdentifier()
        passwordTextField?.accessibilityIdentifier = AccessibilityUnrememberedLogin.inputTextPassword.rawValue
        documentTextField?.loginTypeBackView?.accessibilityIdentifier = AccessibilityUnrememberedLogin.btnArrowDown.rawValue
        passwordTextField?.showBackView?.accessibilityIdentifier = AccessibilityUnrememberedLogin.btnEyeOpen.rawValue
        rememberMeView?.checkButton?.accessibilityIdentifier = AccessibilityUnrememberedLogin.btnCheck.rawValue
        rememberMeView?.checkButton?.titleLabel?.accessibilityIdentifier = AccessibilityUnrememberedLogin.btnCheckLabel.rawValue
        rememberMeView?.label?.accessibilityIdentifier = CoreFoundationLib.AccessibilityUnrememberedLogin.rememberLabel.rawValue
        rememberMeView?.accessibilityIdentifier = AccessibilityUnrememberedLogin.rememberMeView.rawValue
        loginButton?.accessibilityIdentifier = AccessibilityUnrememberedLogin.btnEnter.rawValue
        loginButton?.titleLabel?.accessibilityIdentifier = AccessibilityUnrememberedLogin.btnEnterLabel.rawValue
        restoreButton?.accessibilityIdentifier = AccessibilityUnrememberedLogin.btnLostKey.rawValue
        restoreButton?.titleLabel?.accessibilityIdentifier = AccessibilityUnrememberedLogin.btnLostKeyLabel.rawValue
        loginDropDownView.accessibilityIdentifier = AccessibilityUnrememberedLogin.loginDropDownView.rawValue
    }
    
    func regardNow() -> String {
        return localized(TimeImageAndGreetingViewModel().greetingTextKey.rawValue).text
    }
    
    func addKeyboardObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func removeKeyboardObserver() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func loginButtonDidPressed() {
        TopAlertController.shared.removeAlert()
        guard let identification = documentTextField?.introducedDocument() else { return }
        guard let magic = passwordTextField?.introducedPassword() else { return }
        guard let remember = rememberMeView?.remember() else { return }
        let type = loginDropDownView.getTypeSelected()
        passwordTextField?.textField?.resignFirstResponder()
        presenter.login(identification: identification, magic: magic, type: type, remember: remember)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        self.loginDropDownView.hideDropDown()
        self.documentTextField?.setDocumentTextField(type: self.loginDropDownView.getTypeSelected(), isDropDownPresent: self.loginDropDownView.getIsDropDownPresent())
        guard  let keyboardFrameValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
            return
        }
        let keyboardFrame: CGRect = keyboardFrameValue.cgRectValue
        bottonDistance?.constant = keyboardFrame.height
        if let loginButton = loginButton {
            view.bringSubviewToFront(loginButton)
        }
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.regardLabel?.alpha = 0.0
            self?.view.layoutSubviews()
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        bottonDistance?.constant = 0
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.regardLabel?.alpha = 1.0
            self?.view.layoutSubviews()
        }
    }
    
    func checkDemoLogin() {
        let compilation = self.dependenciesResolver.resolve(for: CompilationProtocol.self)
        guard let demoLogin = compilation.debugLoginSetup else { return }
        documentTextField?.setText(demoLogin.defaultUser)
        passwordTextField?.setText(demoLogin.defaultMagic)
    }
}

extension UnrememberedLoginViewController: RootMenuController {
    public var isSideMenuAvailable: Bool {
        return true
    }
}

extension UnrememberedLoginViewController: DropDownProtocol {
    public func loginTypeSelected(type: LoginIdentityDocumentType) {
        documentTextField?.setLoginType(type)
        documentTextField?.setPlaceholder(localized("login_hint_documentNumber").text)
        self.documentTextField?.setDocumentTextField(type: type, isDropDownPresent: self.loginDropDownView.getIsDropDownPresent())
    }
}

extension UnrememberedLoginViewController: DocumentTextProtocol {
    public func dropDownButtonDidPressed() {
        if !loginDropDownView.getIsDropDownPresent() {
            view.bringSubviewToFront(loginDropDownView)
        }
        loginDropDownView.refreshPosition(viewPositionReference: view.convert(documentTextField?.frame ?? .zero, from: documentTextField))
        self.loginDropDownView.toogleDropDown()
        documentTextField?.setPlaceholder((
            loginDropDownView.getIsDropDownPresent() ?
                localized("login_text_selectDocument"):
                localized( "login_hint_documentNumber")).text)
        self.documentTextField?.setDocumentTextField(type: self.loginDropDownView.getTypeSelected(), isDropDownPresent: self.loginDropDownView.getIsDropDownPresent())
    }
}

extension UnrememberedLoginViewController: ForcedRotatable {
    public func forcedOrientationForPresentation() -> UIInterfaceOrientation {
        .portrait
    }
}

extension UnrememberedLoginViewController: NotRotatable { }
