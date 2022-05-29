import UIKit
import IQKeyboardManagerSwift
import CoreFoundationLib
import UI

protocol GenericOtpPresenterProtocol: Presenter {
    var maxLength: Int { get }
    var characterSet: CharacterSet { get }
    var navigationBarTitle: String? { get }
    var showsHelpButton: Bool { get }
    func validateOtp()
    func helpButtonTouched()
    func didSelectHelp()
    func dismiss()
    func close()
    func trackFaqEvent(_ question: String, url: URL?)
}

extension GenericOtpPresenterProtocol {
    var navigationBarTitle: String? {
        return nil
    }
    
    // When not necessary
    func didSelectHelp() {}
    func trackFaqEvent(_ question: String, url: URL?){}
}
class GenericOtpViewController: BaseViewController<GenericOtpPresenterProtocol>, ChangeTextFieldDelegate {
   
    @IBOutlet weak var titleOtp: UILabel!
    @IBOutlet weak var subtitleOtp: UILabel!
    @IBOutlet weak var otpTextField: CustomTextField! {
        didSet {
            if #available(iOS 12.0, *) {
                otpTextField.textContentType = .oneTimeCode
            }
        }
    }
    @IBOutlet weak var helpButton: UIButton!
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var bottomSeparator: UIView!
    var isVisible = true
    
    //Margin
    @IBOutlet weak var bottomMarginAcceptButton: NSLayoutConstraint!
    
    override var progressBarBackgroundColor: UIColor? {
        return .uiBackground
    }
    
    override class var storyboardName: String {
        return genericSignatureStoryboardName
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if #available(iOS 12.0, *) {
            otpTextField.becomeFirstResponder()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        isVisible = false
        view.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.backgroundColor = .uiBackground
        isVisible = true
        setupNavigationBar()
    }
    
    override func prepareView() {
        super.prepareView()
        setupViews()
    }
    
    func setupViews() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        styledTitle = stringLoader.getString("toolbar_title_otp")
        titleOtp.set(localizedStylableText: stringLoader.getString("otp_text_sms"))
        titleOtp.applyStyle(LabelStylist(textColor: .sanRed, font: UIFont.latoSemibold(size: 20), textAlignment: .center))
        subtitleOtp.set(localizedStylableText: stringLoader.getString("otp_text_insertCode_old"))
        subtitleOtp.applyStyle(LabelStylist(textColor: .uiBlack, font: UIFont.latoLight(size: 17), textAlignment: .center))
        helpButton.applyStyle(ButtonStylist(textColor: .sanRed,
                                            font: UIFont.latoRegular(size: 16),
                                            borderColor: nil, borderWidth: nil,
                                            backgroundColor: nil))
        helpButton.set(localizedStylableText: stringLoader.getString("otp_text_notReceived"), state: .normal)
        
        acceptButton.set(localizedStylableText: stringLoader.getString("generic_button_accept"), state: .normal)
        acceptButton.layer.cornerRadius = 20
        acceptButton.applyStyle(ButtonStylist.genericSignatureAcceptButton)
        acceptButton.set(localizedStylableText: stringLoader.getString("generic_button_accept"), state: .normal)
        otpTextField.customDelegate = self
        otpTextField.formattedDelegate.maxLength = presenter.maxLength
        otpTextField.formattedDelegate.characterSet = presenter.characterSet
        (otpTextField as UITextField).applyStyle(TextFieldStylist(textColor: .sanRed, font: UIFont.latoLight(size: 19), textAlignment: .center))
        bottomSeparator.backgroundColor = .lisboaGray
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
    }
    
    func showNotAvailable() {
        Toast.show(localized(key: "generic_alert_notAvailableOperation").text)
    }
    
    // MARK: - IBActions
    
    @IBAction func acceptButtonAction(_ sender: UIButton) {
        presenter.validateOtp()
    }
    
    @IBAction func helpButtonAction(_ sender: UIButton) {
        presenter.helpButtonTouched()
    }

    // MARK: - KeyboardNotifications
    @objc func keyboardDidShow(_ notification: Notification) {
        if let userInfo = notification.userInfo, let keyboardSize = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size, let window = UIApplication.shared.keyWindow {
            
            let bottomPadding: CGFloat
            if #available(iOS 11.0, *) {
                bottomPadding = window.safeAreaInsets.bottom
            } else {
                bottomPadding = 0
            }
            
            bottomMarginAcceptButton.constant = keyboardSize.height - bottomPadding
            view.updateConstraints()
            view.layoutIfNeeded()
        }
    }
    
    @objc func keyboardDidHide(_ notification: Notification) {
        bottomMarginAcceptButton.constant = 0
    }
    
    // MARK: - Privates
    func enableAcceptButton() {
        acceptButton.backgroundColor = .sanRed
        acceptButton.isEnabled = true
    }
    
    private func disableAcceptButton() {
        acceptButton.backgroundColor = .lisboaGray
        acceptButton.isEnabled = false
    }
    
    // MARK: - Textfield Delegate
    func willChangeText(textField: UITextField, text: String) {
        if text.count == presenter.maxLength {
            enableAcceptButton()
        } else {
            disableAcceptButton()
        }
    }
    
    func showFaqs(_ items: [FaqsItemViewModel]) {
        let data = FaqsViewData(items: items)
        data.show(in: self)
    }
    
    func enableOtpTextField(_ enabled: Bool) {
        otpTextField.isEnabled = enabled
    }
}

extension GenericOtpViewController: FaqsViewControllerDelegate {
    func didExpandAnswer(question: String) {
        presenter.trackFaqEvent(question, url: nil)
    }
    
    func didTapAnswerLink(question: String, url: URL) {
        presenter.trackFaqEvent(question, url: url)
    }
}

private extension GenericOtpViewController {
    func setupNavigationBar() {
        var navigationBarBuilder: NavigationBarBuilder
        if let headerKey = presenter.navigationBarTitle {
            navigationBarBuilder = NavigationBarBuilder(
                style: .custom(background: NavigationBarBuilder.Background.color(UIColor.uiBackground), tintColor: .santanderRed),
                title: .titleWithHeader(titleKey: "toolbar_title_otp",
                                        header: .title(key: headerKey, style: .default)))
        } else {
            navigationBarBuilder = NavigationBarBuilder(
                style: .custom(background: NavigationBarBuilder.Background.color(UIColor.uiBackground), tintColor: .santanderRed),
                title: .title(key: "toolbar_title_otp"))
        }
        navigationBarBuilder.setLeftAction(.back(action: #selector(back)))
        if self.presenter.showsHelpButton {
            navigationBarBuilder.setRightActions(.close(action: #selector(close)), .help(action: #selector(help)))
        } else {
             navigationBarBuilder.setRightActions(.close(action: #selector(close)))
        }
        navigationBarBuilder.build(on: self, with: nil)
    }
    
    @objc private func back() {
        presenter.dismiss()
    }
    
    @objc private func help() {
        presenter.didSelectHelp()
    }
    
    @objc private func close() {
        otpTextField.resignFirstResponder()
        presenter.close()
    }
    
    func setAccessibility() {
        otpTextField.accessibilityLabel = "\(titleOtp.text ?? "")"
    }
}
