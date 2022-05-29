import UIKit
import UI
import CoreFoundationLib
import IQKeyboardManagerSwift

final class LisboaGenericOtpViewController: BaseViewController<GenericOtpPresenterProtocol> {
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
    @IBOutlet private weak var bottomConstraint: NSLayoutConstraint!
    
    override class var storyboardName: String {
        return "LisboaGenericOtp"
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) {
            return .darkContent
        } else {
            return .default
        }
    }
    
    override var progressBarBackgroundColor: UIColor? {
        return .sky30
    }
    
    override var isKeyboardDismisserActivated: Bool {
        return false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.endEditing(false)
        NotificationCenter.default.removeObserver(self,
                                                  name: UIResponder.keyboardWillShowNotification,
                                                  object: nil)
        NotificationCenter.default.removeObserver(self,
                                                  name: UIResponder.keyboardWillHideNotification,
                                                  object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.backgroundColor = .white
        setupNavigationBar()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    
    func setupNavigationBar() {
        var navigationBarBuilder: NavigationBarBuilder
        if let headerKey = presenter.navigationBarTitle {
            navigationBarBuilder = NavigationBarBuilder(
                style: .sky,
                title: .titleWithHeader(titleKey: "toolbar_title_otp",
                                        header: .title(key: headerKey, style: .default)))
        } else {
            navigationBarBuilder = NavigationBarBuilder(
                style: .sky,
                title: .title(key: "toolbar_title_otp"))
        }
        navigationBarBuilder.setLeftAction(.back(action: #selector(didTapBack)))
        if self.presenter.showsHelpButton {
            navigationBarBuilder.setRightActions(.close(action: #selector(didTapClose)), .help(action: #selector(didTapHelp)) )
        } else {
            navigationBarBuilder.setRightActions(.close(action: #selector(didTapClose)))
        }
        navigationBarBuilder.build(on: self, with: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
    
    override func prepareView() {
        super.prepareView()
        setupViews()
    }
    
    func setupViews() {
        IQKeyboardManager.shared.enableAutoToolbar = false
        titleOtp.set(localizedStylableText: stringLoader.getString("otp_text_sms"))
        titleOtp.applyStyle(LabelStylist(textColor: .lisboaGrayNew, font: UIFont.santander(family: .text, type: .bold, size: 18), textAlignment: .center))
        subtitleOtp.applyStyle(LabelStylist(textColor: .uiBlack, font: UIFont.santander(family: .text, type: .light, size: 18), textAlignment: .center))
        subtitleOtp.isHidden = true
        
        sendAgainButton.applyStyle(ButtonStylist(textColor: .santanderRed,
                                                 font: UIFont.santander(family: .text, type: .regular, size: 15),
                                                 borderColor: nil, borderWidth: nil,
                                                 backgroundColor: nil))
        sendAgainButton.set(localizedStylableText: stringLoader.getString("otpSCA_link_notCode"), state: .normal)
        acceptButton.set(localizedStylableText: stringLoader.getString("generic_button_accept"), state: .normal)
        acceptButton.addSelectorAction(target: self, #selector(didTouchAcceptButton))
        
        textFieldSeparator.backgroundColor = .darkTurqLight
        (otpTextField as UITextField).applyStyle(TextFieldStylist(textColor: .lisboaGrayNew, font: UIFont.santander(size: 18), textAlignment: .center))
        otpTextField.tintColor = .darkTurqLight
        otpTextField.backgroundColor = .sky30
        otpTextField.layer.borderColor = UIColor.mediumSkyGray.cgColor
        otpTextField.layer.borderWidth = 1.0
        otpTextField.configure(maxLength: presenter.maxLength, characterSet: presenter.characterSet)
        otpTextField.delegate = self
        otpTextField.returnKeyType = .done
        
        disableAcceptButton()
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
    }
    
    func setSubtitle(text: LocalizedStylableText) {
        subtitleOtp.set(localizedStylableText: text)
        subtitleOtp.isHidden = false
        self.otpTextField.becomeFirstResponder()
    }
    
    func enableAcceptButton() {
        acceptButton.configureAsRedButton()
        acceptButton.layer.cornerRadius = acceptButton.frame.height / 2.0
        acceptButton.isEnabled = true
    }
    
    // MARK: - IBActions
    
    @objc func didTapBack() {
        presenter.dismiss()
    }
    @objc func didTapClose() {
        presenter.close()
    }
    @objc func didTapHelp() {
        presenter.didSelectHelp()
    }
    
    @objc func didTouchAcceptButton() {
        presenter.validateOtp()
    }
    
    @IBAction func didTouchSendAgainButton() {
        presenter.helpButtonTouched()
    }
    
    func showFaqs(_ items: [FaqsItemViewModel]) {
        let data = FaqsViewData(items: items)
        data.show(in: self)
    }
}

private extension LisboaGenericOtpViewController {
    
    func disableAcceptButton() {
        acceptButton.configureAsWhiteButton()
        acceptButton.layer.cornerRadius = acceptButton.frame.height / 2.0
        acceptButton.isEnabled = false
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber else { return }
        guard let curve = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber else { return }
        guard let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        
        self.bottomConstraint.constant = keyboardFrame.height + 5.0
        UIView.animate(withDuration: TimeInterval(truncating: duration),
                   delay: 0,
                   options: [UIView.AnimationOptions(rawValue: UInt(truncating: curve))],
                   animations: { [weak self] in
                    self?.view.layoutIfNeeded()
        },
                   completion: nil)
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber else { return }
        guard let curve = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber else { return }
        self.bottomConstraint.constant = 0
        UIView.animate(withDuration: TimeInterval(truncating: duration),
                       delay: 0,
                       options: [UIView.AnimationOptions(rawValue: UInt(truncating: curve))],
                       animations: { [weak self] in
                        self?.view.layoutIfNeeded()
            },
                       completion: nil)
    }
}

extension LisboaGenericOtpViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard var text = textField.text, let range = Range(range, in: text) else { return true }
        text.replaceSubrange(range, with: string)
        if text.count == presenter.maxLength {
            enableAcceptButton()
        } else {
            disableAcceptButton()
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if acceptButton.isEnabled {
            textField.endEditing(true)
            didTouchAcceptButton()
        }
        return true
    }
}

extension LisboaGenericOtpViewController: ModuleViewController {}
