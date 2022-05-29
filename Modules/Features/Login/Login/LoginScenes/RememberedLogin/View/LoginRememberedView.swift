//
//  LoginRememberedView.swift
//  Login
//
//  Created by Juan Carlos López Robles on 12/3/20.
//

import UI
import CoreFoundationLib
import Foundation
import IQKeyboardManagerSwift

protocol LoginRememberedViewProtocol: class, BiometryLoginView {
    func autocompletePasswordWith(_ defaultMagic: String?)
    func setSantanderLogoViewModel(_ viewModel: SantanderLogoViewModel)
    func setDefaultBackgroundImage()
    func setBackgroundViewModel(_ viewModel: RememberedLoginBackgroundViewModel)
    func setGreeting(_ greeting: String?)
    func showOTPCode(_ viewModel: OTPCodeViewModel)
    func disableUserInteraction()
    func enableUserInteraction()
    func didAccessWithWrongPassword()
    func clearPassword()
    func didTapOnAccessPassword()
    func hideOtpCode()
    func expandOtpCode()
    func displayEcommerceView(_ display: Bool)
}

final class LoginRememberedViewController: UIViewController {
    let dependenciesResolver: DependenciesResolver
    private let presenter: LoginRememberedPresenterProtocol
    private let headerLeadingConstraint: CGFloat = 25.0
    private var alertView: StickyBottomAlert?
    private let greatingFormater = GreatingFormater()
    private var loginViewAdded: LoginCustomizable?
    public var isSideMenuAvailable: Bool = true
    @IBOutlet weak var environmentButton: UIButton?
    @IBOutlet private weak var santanderLogoImage: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var balanceButton: UIButton!
    @IBOutlet private weak var changeUserButton: UIButton!
    @IBOutlet private weak var loginViewContainer: UIStackView!
    @IBOutlet private weak var headerContainerView: UIView!
    @IBOutlet private weak var leadingConstraint: NSLayoutConstraint!
    @IBOutlet private weak var backgroundImage: UIImageView!
    @IBOutlet private weak var backgroundCoverView: UIView!

    lazy var numberPadView: NumberPadLoginView = {
        let loginView = NumberPadLoginView(frame: .zero)
        loginView.setOkButtonText(localized("login_keyboard_ok"))
        loginView.setFooter()
        loginView.delegate = self
        return loginView
    }()
    
    lazy var touchIDView: TouchIDLoginView = {
        let loginView = TouchIDLoginView(frame: .zero)
        loginView.setTouchIDText(localized("login_label_accessFingerprint"))
        loginView.setFooter()
        loginView.delegate = self
        return loginView
    }()
    
    lazy var faceIDView: FaceIDLoginView = {
        let loginView = FaceIDLoginView(frame: .zero)
        loginView.setFaceIDText(localized("loginRegistered_faceId_access"))
        loginView.setFooter()
        loginView.delegate = self
        return loginView
    }()
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    init(nibName: String?, bundle: Bundle?,
         dependenciesResolver: DependenciesResolver,
         presenter: LoginRememberedPresenterProtocol) {
        self.dependenciesResolver = dependenciesResolver
        self.presenter = presenter
        super.init(nibName: nibName, bundle: bundle)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.presenter.viewDidLoad()
        self.setupEnvironmentButton()
        self.setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setnavigationBar()
        self.presenter.viewWillAppear()
        self.setupLoginViews()
        self.forceOrientationForPresentation()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.presenter.viewDidAppear()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.presenter.viewWillDisappear()
    }
    
    func setnavigationBar() {
        NavigationBarBuilder(style: .clear(tintColor: .white), title: .none)
            .setRightActions(.menu(action: #selector(didSelectMenu)))
            .build(on: self, with: nil)
    }
    
    @IBAction func didSelectChangeEnvironment(_ sender: Any) {
        self.chooseEnvironment()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.stopWaitingForUserInteraction()
    }
}

extension LoginRememberedViewController: LoginRememberedViewProtocol {
    public func shakeWasOccurred() {
        self.presenter.didShakeWasOccurred()
    }
    
    func chooseEnvironment() {
        self.presenter.didSelectChooseEnvironment()
    }
    
    func didUpdateEnvironments() {
        IQKeyboardManager.shared.enableAutoToolbar = false
    }
    
    func autocompletePasswordWith(_ defaultMagic: String?) {
        self.numberPadView.autocompletePasswordWith(defaultMagic)
    }
    
    func setSantanderLogoViewModel(_ viewModel: SantanderLogoViewModel) {
        let image = Assets.image(named: viewModel.logo())
        self.santanderLogoImage.image = image
        self.setAspectRatioToSantanderLogo(image)
    }
    
    func setDefaultBackgroundImage() {
        self.backgroundImage.image = TimeImageAndGreetingViewModel().backgroundImage
        self.backgroundImage.accessibilityIdentifier = AccessibilityRememberedLogin.backgroundImageView.rawValue
    }
    
    func setBackgroundViewModel(_ viewModel: RememberedLoginBackgroundViewModel) {
        switch viewModel.image() {
        case .assets(let name):
            self.backgroundImage.image = Assets.image(named: name)
            self.backgroundImage.accessibilityIdentifier = String(name[..<(name.lastIndex(of: "_") ?? name.endIndex)])
        case .documents(let data):
            self.backgroundImage.image = UIImage(data: data)
            self.backgroundImage.accessibilityIdentifier = AccessibilityRememberedLogin.backgroundImageView.rawValue
        }
    }
    
    func setGreeting(_ greeting: String?) {
        let greetingText = self.greatingFormater.setUpGreetingText(with: greeting)
        self.setGreetingText(greetingText)
    }
    
    func showOTPCode(_ viewModel: OTPCodeViewModel) {
        if self.alertView == nil {
            self.alertView = StickyBottomAlert.otpNotificationMode()
        }
        self.alertView?.setExpandedInfo(viewModel)
        self.alertView?.delegate = self
        self.alertView?.show(in: self.view)
    }

    func disableUserInteraction() {
        self.view.isUserInteractionEnabled = false
    }
    
    func enableUserInteraction() {
        self.view.isUserInteractionEnabled = true
    }
    
    func didAccessWithWrongPassword() {
        self.numberPadView.wrongPassword()
    }
    
    func clearPassword() {
        self.numberPadView.clear()
    }
    
    func hideOtpCode() {
        self.alertView?.dismiss()
    }
    
    func expandOtpCode() {
        self.alertView?.expandView()
    }
    
    func enableTouchIDView() {
        self.touchIDView.enableTouchIDView()
    }
    
    func displayEcommerceView(_ display: Bool) {
        self.loginViewAdded?.setEcommerceEnabled(display)
    }
}

extension LoginRememberedViewController: StickyBottomAlertDelegate {
    func dismissed() {
        self.alertView = nil
        self.presenter.onAlertDismissed()
    }
}

extension LoginRememberedViewController: BiometryLoginView {
    func setAvailableBiometryType(_ biometryType: BiometryTypeEntity) {
        self.numberPadView.setAvailableBiometryType(biometryType)
    }
    
    func displayLoginWithTouchIDView() {
        self.addLoginView(touchIDView)
        self.presenter.updateEcommerceEnabledState()
        self.touchIDView.startWaitingForUserInteraction(seconds: 5)
    }
    
    func displayLoginWithNumberPadView() {
        self.addLoginView(numberPadView)
        self.presenter.updateEcommerceEnabledState()
    }
    
    func displayLoginWithFaceIDView() {
        self.addLoginView(faceIDView)
        self.presenter.updateEcommerceEnabledState()
        self.faceIDView.startWaitingForUserInteraction(seconds: 5)
    }
    
    func disableTouchIDView() {
        self.touchIDView.disableTouchIDView()
    }
    
    func enableSideMenu() {
        self.isSideMenuAvailable = true
    }
    
    func disableSideMenu() {
        self.isSideMenuAvailable = false
    }
    
    func isViewActive(completion: @escaping (Bool) -> Void) {
        guard self.presentedViewController == nil,
              self.navigationController?.viewControllers.last == self else {
                completion(false)
                return
        }
        completion(true)
    }
    
    func showBiometryDialog(titleKey: String, descriptionKey: String,
                            acceptKey: String,
                            onAccept: @escaping () -> Void, onClose: @escaping () -> Void) {
        BiometryDialog().makeLisboaDialog(
            titleKey: titleKey,
            descriptionKey: descriptionKey,
            acceptKey: acceptKey,
            onAccept: onAccept, onClose: onClose)
            .showIn(self)
    }
}

extension LoginRememberedViewController: NumberPadLoginViewDelegate {
    
    func didTapOnTouchID() {
        self.presenter.performBiometryAction()
    }
    
    func didTapOnFaceID() {
        self.presenter.performBiometryAction()
    }
    
    func didTapOnRestorePassword() {
        self.presenter.recoverUserPassword()
    }
    
    func didTapOnOK(withMagic magic: String) {
        self.presenter.loginWithMagic(magic)
    }
    
    func didTapSantanderKey() {
        self.presenter.didTapSantanderKey()
    }
}

extension LoginRememberedViewController: TouchIDLoginViewDelegate, FaceIDLoginViewDelegate {
    func didTapOnAccessPassword() {
        self.displayLoginWithNumberPadView()
    }
    
    func didTapOnAccessWithTouchID() {
        self.presenter.performBiometryAction()
    }
    
    func didTapOnAccessWithFaceID() {
        self.presenter.performBiometryAction()
    }
    
    func didFinishWrongPasswordAnimation() {
        self.enableUserInteraction()
    }
    
    func didTapOnEcommerce() {
        self.presenter.didTapSantanderKey()
    }
}

private extension LoginRememberedViewController {
    func setupLoginViews() {
        self.loginViewContainer.alpha = 1.0
        self.showGreetingsViews()
        self.showChangeUserButton()
        self.enableUserInteraction()
    }
    
    func setupViews() {
        self.configureSantanderLogo()
        self.setGestures()
        self.backgroundCoverView?.backgroundColor = UIColor.clear
        self.setChangeUserText()
        self.balanceButton.setImage(Assets.image(named: "icnBalance"), for: .normal)
        self.setAccessibilityIds()
    }
    
    func setGestures() {
        let tapOnChangeUserGesture =
            UITapGestureRecognizer(target: self, action: #selector(didTapOnChangeUser))
        changeUserButton.addGestureRecognizer(tapOnChangeUserGesture)
        let tapOnQuickBalanceGesture = UITapGestureRecognizer(target: self, action: #selector(tapOnQuickBalance))
        self.balanceButton.addGestureRecognizer(tapOnQuickBalanceGesture)
    }
    
    @objc func didTapOnChangeUser() {
        self.stopWaitingForUserInteraction()
        self.presenter.changeUser()
    }
    
    @objc func tapOnQuickBalance() {
        self.presenter.quickBalance()
    }
    
    func setChangeUserText() {
        self.changeUserButton.setTitle(localized("loginRegistered_button_changeUser"), for: .normal)
        self.changeUserButton.contentHorizontalAlignment = .left
    }
    
    func configureSantanderLogo() {
        santanderLogoImage.contentMode = .scaleAspectFit
    }
    
    func setAspectRatioToSantanderLogo(_ image: UIImage?) {
        guard let image = image else { return }
        let aspectRatio = image.size.width / image.size.height
        self.santanderLogoImage.widthAnchor.constraint(equalTo: santanderLogoImage.heightAnchor, multiplier: aspectRatio).isActive = true
        self.santanderLogoImage.widthAnchor.constraint(lessThanOrEqualTo: headerContainerView.widthAnchor, multiplier: 0.7).isActive = true
    }
    
    func showGreetingsViews() {
        self.headerContainerView.alpha = 1.0
        self.leadingConstraint.constant = self.headerLeadingConstraint
        self.changeUserButton.frame.origin.y -= 10
    }
    
    func showChangeUserButton() {
        self.changeUserButton.alpha = 1.0
        self.changeUserButton.frame.origin.y += 10
    }
    
    func stopWaitingForUserInteraction() {
        guard let currentLoginView = loginViewContainer.arrangedSubviews.first else { return }
        guard let expireble = currentLoginView as? Expirable else { return }
        expireble.stopWaitingForUserInteraction()
    }
    
    func addLoginView(_ loginView: UIView) {
        self.removeLoginContainerSubviews()
        self.loginViewContainer.addArrangedSubview(loginView)
        self.loginViewContainer.layoutIfNeeded()
        self.loginViewAdded = loginView as? LoginCustomizable
        loginView.layoutSubviews()
    }
    
    func removeLoginContainerSubviews() {
        self.loginViewContainer.arrangedSubviews.forEach {
            $0.removeFromSuperview()
        }
    }
    
    @objc func didSelectMenu() {
        self.presenter.didSelectMenu()
    }
    
    func setGreetingText(_ greeting: NSAttributedString?) {
        self.nameLabel.attributedText = greeting
        self.nameLabel.set(lineHeightMultiple: 0.70)
        self.nameLabel.adjustsFontSizeToFitWidth = true
        self.nameLabel.minimumScaleFactor = 0.5
        self.nameLabel.lineBreakMode = .byTruncatingTail
        self.nameLabel.numberOfLines = 2
    }
    
    func setAccessibilityIds() {
        environmentButton?.accessibilityIdentifier = AccessibilityRememberedLogin.btnEnvironment.rawValue
        environmentButton?.titleLabel?.accessibilityIdentifier = AccessibilityRememberedLogin.btnEnvironmentLabel.rawValue
        santanderLogoImage.accessibilityIdentifier = AccessibilityRememberedLoginView.santanderLogoImage
        nameLabel.accessibilityIdentifier = AccessibilityRememberedLoginView.nameLabel
        balanceButton.accessibilityIdentifier = AccessibilityRememberedLogin.btnBalance.rawValue
        balanceButton?.titleLabel?.accessibilityIdentifier = AccessibilityRememberedLogin.btnBalanceLabel.rawValue
        changeUserButton.accessibilityIdentifier = AccessibilityRememberedLoginView.changeUserButton
        changeUserButton?.titleLabel?.accessibilityIdentifier = AccessibilityRememberedLogin.btnChangeUserLabel.rawValue
        loginViewContainer.accessibilityIdentifier = AccessibilityRememberedLogin.loginContainer.rawValue
        headerContainerView.accessibilityIdentifier = AccessibilityRememberedLogin.headerView.rawValue
        backgroundCoverView.accessibilityIdentifier = AccessibilityRememberedLogin.backgroundCoverView.rawValue
    }
}

extension LoginRememberedViewController: RootMenuController {}

extension LoginRememberedViewController: ForcedRotatable {
    func forcedOrientationForPresentation() -> UIInterfaceOrientation {
        return .portrait
    }
}

extension LoginRememberedViewController: NotRotatable { }
