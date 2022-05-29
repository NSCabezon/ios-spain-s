import UIKit
import CoreFoundationLib
import UI

protocol OtpScaLoginPresenterProtocol: Presenter {
    func validateOtp()
    func close()
    func resend()
}

class OtpScaLoginViewController: BaseViewController<OtpScaLoginPresenterProtocol> {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var otpTextField: CustomTextField! {
        didSet {
            if #available(iOS 12.0, *) {
                otpTextField.textContentType = .oneTimeCode
            }
        }
    }
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var buttonRemember: UIButton!
    @IBOutlet weak var bottomSeparation: NSLayoutConstraint!
    @IBOutlet weak var fakeNavigationHeight: NSLayoutConstraint!
    @IBOutlet weak var fakeNavigationImage: UIImageView!
    @IBOutlet weak var fakeNavigationBack: UIImageView!
    @IBOutlet weak var fakeNavigationBackGesture: UIView!
    @IBOutlet weak var fakeNavigationBar: UIView!
    
    override static var storyboardName: String {
        return "Sca"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addKeyboardObserver()
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeKeyboardObserver()
        navigationController?.isNavigationBarHidden = false
    }
    
    override func prepareView() {
        super.prepareView()
        configureView()
        configureTextField()
        configureLabels()
        configureButtons()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) {
            return .darkContent
        } else {
            return .default
        }
    }
    
    // MARK: - Public Methods
    
    func focusTextField() {
        otpTextField.becomeFirstResponder()
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
    
    func set(maxLength: Int, characterSet: CharacterSet) {
        otpTextField.formattedDelegate.maxLength = maxLength
        otpTextField.formattedDelegate.characterSet = characterSet
    }
    
    func set(acceptText: LocalizedStylableText) {
        acceptButton.set(localizedStylableText: acceptText, state: .normal)
    }
    
    func set(titleText: LocalizedStylableText) {
        titleLabel.set(localizedStylableText: titleText)
    }
    
    func set(subtitleText: LocalizedStylableText) {
        subtitleLabel.set(localizedStylableText: subtitleText)
    }
    
    func set(infoText: LocalizedStylableText) {
        infoLabel.set(localizedStylableText: infoText)
    }
    
    func set(buttonRememberText: LocalizedStylableText) {
        buttonRemember.set(localizedStylableText: buttonRememberText, state: .normal)
    }
    
    func setNormalImageInTitle() { }
    
    func enableAcceptButton() {
        acceptButton.setTitleColor(.white, for: .normal)
        acceptButton.backgroundColor = .santanderRed
        acceptButton.isEnabled = true
    }
    
    // MARK: - Private methods
    
    private func configureView() {
        fakeNavigationHeight.constant = UIApplication.shared.statusBarFrame.size.height + (navigationController?.navigationBar.frame.height ?? 44.0)
        fakeNavigationImage.image = Assets.image(named: "icnSanRedComplete")
        fakeNavigationBack.image = Assets.image(named: "icnArrowLeftRedNew")
        fakeNavigationBackGesture.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backTapped)))
        fakeNavigationBackGesture.isUserInteractionEnabled = true
        fakeNavigationBar.backgroundColor = UIColor.white
        view.backgroundColor = UIColor.white
        separatorView.backgroundColor = UIColor(red: 140.0/255.0, green: 186.0/255.0, blue: 189.0/255.0, alpha: 1.0)
    }
    
    private func configureTextField() {
        otpTextField.customDelegate = self
        (otpTextField as UITextField).applyStyle(TextFieldStylist(textColor: .lisboaGrayNew, font: UIFont.santander(family: .text, size: 17), textAlignment: .center))
        otpTextField.layer.borderWidth = 1
        otpTextField.layer.borderColor = UIColor(red: 219.0/255.0, green: 224.0/255.0, blue: 227.0/255.0, alpha: 1.0).cgColor
        otpTextField.backgroundColor = UIColor.bg
        otpTextField.tintColor = UIColor(red: 140.0/255.0, green: 186.0/255.0, blue: 189.0/255.0, alpha: 1.0)
        otpTextField.autocorrectionType = .no
        otpTextField.delegate = self
    }
    
    private func configureLabels() {
        titleLabel.applyStyle(LabelStylist(textColor: .lisboaGrayNew, font: UIFont.santander(family: .headline, type: .bold, size: 28), textAlignment: .left))
        subtitleLabel.applyStyle(LabelStylist(textColor: .lisboaGrayNew, font: UIFont.santander(family: .text, type: .light, size: 16), textAlignment: .left))
        infoLabel.applyStyle(LabelStylist(textColor: .lisboaGrayNew, font: UIFont.santander(family: .text, type: .light, size: 16), textAlignment: .left))
    }
    
    private func configureButtons() {
        buttonRemember.set(localizedStylableText: stringLoader.getString("generic_button_accept"), state: .normal)
        buttonRemember.applyStyle(ButtonStylist(textColor: .santanderRed, font: UIFont.santander(family: .text, size: 15)))
        
        acceptButton.titleLabel?.font = UIFont.santanderTextRegular(size: 16)
        acceptButton.layer.borderColor = UIColor.santanderRed.cgColor
        acceptButton.layer.borderWidth = 1.0
        acceptButton.layer.cornerRadius = acceptButton.bounds.height / 2.0
        disableAcceptButton()
    }
    
    private func addKeyboardObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func removeKeyboardObserver() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @IBAction func actionButtonRemember(_ sender: Any) {
        presenter.resend()
    }
    
    @IBAction private func acceptButtonTapped(_ sender: UIButton) {
        otpTextField.endEditing(true)
        presenter.validateOtp()
    }
    
    @IBAction private func backTapped() {
        presenter.close()
    }
    
    private func disableAcceptButton() {
        acceptButton.setTitleColor(UIColor.santanderRed, for: .normal)
        acceptButton.backgroundColor = .white
        acceptButton.isEnabled = false
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let info = notification.userInfo else { return }
        let keyboardFrame: CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        bottomSeparation.constant = keyboardFrame.height
        view.bringSubviewToFront(acceptButton)
        view.bringSubviewToFront(buttonRemember)
        UIView.animate(withDuration: 0.2) { [weak self] in self?.view.layoutIfNeeded() }
    }

    @objc private func keyboardWillHide(notification: NSNotification) {
        bottomSeparation.constant = 0
        UIView.animate(withDuration: 0.2) { [weak self] in self?.view.layoutIfNeeded() }
    }
}

extension OtpScaLoginViewController: ChangeTextFieldDelegate {
    func willChangeText(textField: UITextField, text: String) {
        if text.count == otpTextField.formattedDelegate.maxLength {
            enableAcceptButton()
        } else {
            disableAcceptButton()
        }
    }
}

extension OtpScaLoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if acceptButton.isEnabled {
            presenter.validateOtp()
            return true
        }
        return false
    }
}
