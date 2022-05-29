import UIKit
import UI
import CoreFoundationLib

public protocol OTPViewProtocol: OTPPresentationDelegate {
    var otpText: String { get }
    func showDialogForType(_ type: OTPDialogType)
    func setSubtitle(text: LocalizedStylableText)
    func cleanTextField()
    func updateText(_ text: String)
    func enableAcceptButton()
    func setNavigationBuilderTitle(_ title: String?)
    func showFaqs(_ items: [FaqsItemViewModel])
    func showKeyboard()
}

class OTPViewController: UIViewController {
    
    @IBOutlet weak var titleOtp: UILabel!
    @IBOutlet var subtitleOtp: UILabel!
    @IBOutlet weak var otpTextField: LimitedTextField! {
        didSet {
            if #available(iOS 12.0, *) {
                otpTextField.textContentType = .oneTimeCode
            }
        }
    }
    @IBOutlet weak var textFieldSeparator: UIView!
    @IBOutlet weak var sendAgainButton: UIButton!
    @IBOutlet weak var acceptButton: LisboaButton!
    @IBOutlet weak private var acceptButtonBottomMargin: NSLayoutConstraint!
    var isVisible = true
    var presenter: OTPPresenterProtocol
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) {
            return .darkContent
        } else {
            return .default
        }
    }
    
    private struct Constants {
        static let acceptButtonBottomMargin: CGFloat = 20.0
    }
    
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, presenter: OTPPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.title = localized("toolbar_title_otp")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.presenter.loaded()
        self.setupViews()
        self.presenter.viewDidLoad()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        isVisible = false
        view.endEditing(false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.backgroundColor = .white
        isVisible = true
    }
    
    func setupViews() {
        titleOtp.configureText(withKey: "otp_text_sms",
                               andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .bold, size: 18)))
        titleOtp.textColor = .lisboaGray
        subtitleOtp.textColor = .lisboaGray
        subtitleOtp.isHidden = true
        
        sendAgainButton.setTitleColor(.darkTorquoise, for: .normal)
        sendAgainButton.titleLabel?.setSantanderTextFont(type: .regular, size: 15, color: .darkTorquoise)
        sendAgainButton.setTitle(localized("otp_text_notReceived"), for: .normal)
        acceptButton.setTitle(localized("generic_button_accept"), for: .normal)
        acceptButton.addSelectorAction(target: self, #selector(didTouchAcceptButton))
        
        textFieldSeparator.backgroundColor = .darkTurqLight
        otpTextField.textColor = .lisboaGray
        otpTextField.font = .santander(family: .text, type: .regular, size: 18)
        otpTextField.tintColor = .darkTurqLight
        otpTextField.backgroundColor = .skyGray
        otpTextField.layer.borderColor = UIColor.mediumSkyGray.cgColor
        otpTextField.layer.borderWidth = 1.0
        otpTextField.configure(maxLength: presenter.maxLength, characterSet: presenter.characterSet)
        otpTextField.delegate = self
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardDidShow(_:)),
                                               name: UIResponder.keyboardDidShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardDidHide(_:)),
                                               name: UIResponder.keyboardDidHideNotification,
                                               object: nil)
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        disableAcceptButton()
        setAccessibility()
    }
    
    func valueFromTextField() -> String {
        return otpTextField.text ?? ""
    }
    
    func updateText(_ text: String) {
        otpTextField.text = text
    }
    
    func cleanTextField() {
        otpTextField.text = ""
        disableAcceptButton()
        self.enableTextField(becomeFirstResponderTextField: true)
    }
    
    func setSubtitle(text: LocalizedStylableText) {
        subtitleOtp.configureText(withLocalizedString: text,
                                  andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .light, size: 18)))
        subtitleOtp.isHidden = false
        subtitleOtp.numberOfLines = 2
    }
    
    @objc func hideKeyboard() {
        self.view.endEditing(true)
    }
    
    // MARK: - IBActions
    
    @objc func didTouchAcceptButton() {
        self.disableTextField()
        presenter.validateOtp()
    }
    
    @IBAction func didTouchSendAgainButton() {
        presenter.helpButtonTouched()
    }
    
    func enableAcceptButton() {
        acceptButton.configureAsRedButton()
        acceptButton.layer.cornerRadius = acceptButton.frame.height / 2.0
        acceptButton.isEnabled = true
    }
    
    // MARK: - Privates
    
    private func disableAcceptButton() {
        acceptButton.configureAsWhiteButton()
        acceptButton.layer.cornerRadius = acceptButton.frame.height / 2.0
        acceptButton.isEnabled = false
    }
    
    func showDialog(
        title: String,
        image: String?,
        action: DialogAction,
        items: [DialogItem],
        closeButton: Dialog.CloseButton,
        hasTitleAndNotAlignment: Bool = true
    ) {
        let dialog = Dialog(
            title: title,
            items: items.map({ $0.toDialogItemView() }),
            image: image,
            actionButton: Dialog.Action(title: action.title, style: .red, action: action.action),
            closeButton: closeButton,
            hasTitleAndNotAlignment: hasTitleAndNotAlignment
        )

        dialog.show(in: self)
        self.enableTextField(becomeFirstResponderTextField: false)
    }
}

extension OTPViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard var text = textField.text, let range = Range(range, in: text) else { return true }
        text.replaceSubrange(range, with: string)
        if text.count == self.presenter.maxLength {
            enableAcceptButton()
        } else {
            disableAcceptButton()
        }
        return true
    }
}

extension OTPViewController: OTPViewProtocol {
    func setNavigationBuilderTitle(_ title: String?) {
        setupNavigationBarWithTitle(title)
    }
    
    var code: String {
        return otpText
    }
    
    var operativePresenter: OperativeStepPresenterProtocol {
        self.presenter
    }
    
    var otpText: String {
        guard otpTextField != nil else { return "" }
        return self.otpTextField.text ?? ""
    }
    
    func showDialogForType(_ type: OTPDialogType) {
        switch type {
        case .genenic(type: let genericType):
            switch genericType {
            case .genericOTPDialog: self.showGenericOTPDialog()
            case .notRegisteredDeviceDialog: self.showNotRegisteredDeviceDialog()
            }
        case .otherError(let hasTitleNotAlignment, let errorMessage, let action): self.showOtherErrorDialog(errorMessage: errorMessage, hasTitleNotAlignment: hasTitleNotAlignment, action: action)
        case .serviceDefault(let error, let action): self.showServiceDefaultDialog(error: error, action: action)
        case .wrongOTP(let error, let hasTitleNotAlignmentCenter): self.showWrongOTPDialog(error: error, hasTitleNotAlignmentCenter: hasTitleNotAlignmentCenter)
        case .expired, .revoked, .unknown:
            self.showGenericOTPDialog()
        }
    }

    func showFaqs(_ items: [FaqsItemViewModel]) {
        let data = FaqsViewData(items: items)
        data.show(in: self)
    }
    
    func showKeyboard() {
        self.otpTextField.becomeFirstResponder()
    }
    
}

private extension OTPViewController {
    func setupNavigationBarWithTitle(_ title: String?) {
        var navigationBarBuilder: NavigationBarBuilder
        if let headerKey = title {
            navigationBarBuilder =
                NavigationBarBuilder(
                    style: .sky,
                    title: .titleWithHeader(titleKey: "toolbar_title_otp",
                                            header: .title(key: headerKey, style: .default)))
        } else {
            navigationBarBuilder =
            NavigationBarBuilder(
                style: .sky,
                title: .title(key: "toolbar_title_otp"))
        }
        if self.presenter.showsHelpButton {
            navigationBarBuilder.setRightActions(.close(action: #selector(close)), .help(action: #selector(help)))
        } else {
            navigationBarBuilder.setRightActions(.close(action: #selector(close)))
        }
        navigationBarBuilder.build(on: self, with: nil)
        self.view.backgroundColor = UIColor.skyGray
     }
    @objc private func close() {
        presenter.didTapClose()
    }
    
    @objc private func help() {
        presenter.didSelectHelp()
    }
    
    @objc func keyboardDidShow(_ notification: Notification) {
        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber,
            let curve = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber,
            let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            else { return }
        self.isEditing = true
        var bottomPadding: CGFloat = 0.0
        if #available(iOS 11.0, *) {
            bottomPadding = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0.0
        }
        self.acceptButtonBottomMargin.constant = keyboardFrame.height + Constants.acceptButtonBottomMargin - bottomPadding
        self.view.updateConstraints()
        UIView.animate(withDuration: TimeInterval(truncating: duration),
                       delay: 0,
                       options: [UIView.AnimationOptions(rawValue: UInt(truncating: curve))],
                       animations: { [weak self] in
                        self?.view.layoutIfNeeded()
            }, completion: nil)
    }

    @objc func keyboardDidHide(_ notification: Notification) {
        self.acceptButtonBottomMargin.constant = Constants.acceptButtonBottomMargin
        self.view.setNeedsLayout()
        let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber ?? 0.25
        UIView.animate(withDuration: TimeInterval(truncating: duration)) { [weak self] in
            self?.view.layoutIfNeeded()
        }
    }

    func disableTextField() {
        self.otpTextField.resignFirstResponder()
        self.otpTextField.isUserInteractionEnabled = false
    }

    func enableTextField(becomeFirstResponderTextField: Bool) {
        if becomeFirstResponderTextField {
            self.otpTextField.becomeFirstResponder()
        }
        self.otpTextField.isUserInteractionEnabled = true
    }
    
    func setAccessibility() {
        otpTextField.accessibilityLabel = localized(AccessibilityTransfers.otpTextField)
    }
}

private extension OTPViewController {
    func showGenericOTPDialog() {
        let description = self.createGenericOTPDialogDescription()
        self.showDialog(title: "otp_titlePopup_notReceived",
                              image: nil,
                              action: DialogAction(title: "generic_button_understand", action: {}),
                              items: [.alignedStyledText(description, alignment: .center)],
                              closeButton: .none)
    }
    
    func showNotRegisteredDeviceDialog() {
        self.showDialog(title: "otp_titlePopup_notReceived",
                              image: nil,
                              action: DialogAction(title: "generic_button_understand", action: {}),
                              items: [.alignedStyledText(localized("otp_text_notReceived_otherDevice"), alignment: .center)],
                              closeButton: .none)
    }
    
    func createGenericOTPDialogDescription() -> LocalizedStylableText {
        guard let supportPhone = self.presenter.supportPhone else {
            return localized("otp_alert_retry")
        }
        return localized("otp_text_popup_notReceived", [StringPlaceholder(.phone, supportPhone)])
    }
    
    func showWrongOTPDialog(error: GenericErrorOTPErrorOutput?, hasTitleNotAlignmentCenter: Bool?) {
        let image = "icnAlertError"
        var keyTitle = "otp_titlePopup_error"
        var errorMessage = localized("otp_text_popup_error").text
        var acceptActionMessage = "generic_button_retry"
        var titleNotAlignment = true
        if let hasTitleNotAlignmentCenter = hasTitleNotAlignmentCenter {
            keyTitle = ""
            titleNotAlignment = hasTitleNotAlignmentCenter
            acceptActionMessage = "generic_button_accept"
            errorMessage =  error?.getErrorDesc() ?? localized("otp_text_popup_error")
        }
        let errorDesc = DialogItem.styledText(LocalizedStylableText(text: errorMessage, styles: .none), titleNotAlignment)
        let acceptAction = DialogAction(title: acceptActionMessage, action: { self.cleanTextField() })
        self.showDialog(title: keyTitle, image: image, action: acceptAction, items: [errorDesc], closeButton: .available)
    }
    
    func showOtherErrorDialog(errorMessage: String, hasTitleNotAlignment: Bool?, action: @escaping () -> Void) {
        let keyTitle = ""
        let image = "icnAlertError"
        var titleNotAlignment = true
        if let hasTitleNotAlignment = hasTitleNotAlignment {
            titleNotAlignment = hasTitleNotAlignment
        }
        let errorDesc = DialogItem.styledText(LocalizedStylableText(text: errorMessage, styles: nil), titleNotAlignment)
        let acceptAction = DialogAction(title: "generic_button_accept", action: { self.cleanTextField() })
        self.showDialog(title: keyTitle, image: image, action: acceptAction, items: [errorDesc], closeButton: .none)
    }
    
    func showServiceDefaultDialog(error: GenericErrorOTPErrorOutput?, action: @escaping () -> Void) {
        let keyTitle = ""
        let errorDesc = DialogItem.alignedStyledText(localized(error?.getErrorDesc() ?? ""), alignment: .center)
        let acceptAction = DialogAction(title: "generic_button_accept", action: action)
        let image = "icnAlertError"
        self.showDialog(title: keyTitle, image: image, action: acceptAction, items: [errorDesc], closeButton: .availableWithAction(action))
    }
}
