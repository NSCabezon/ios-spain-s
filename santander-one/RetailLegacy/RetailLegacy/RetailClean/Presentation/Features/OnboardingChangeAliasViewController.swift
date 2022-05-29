import UIKit
import UI
import CoreFoundationLib
import IQKeyboardManagerSwift

final class OnboardingChangeAliasViewController: BaseViewController<OnboardingChangeAliasPresenterProtocol> {
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var textField: LisboaTextfield!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var markLabel: UILabel!
    @IBOutlet private weak var buttonsView: BottomActionsOnboardingView!
    @IBOutlet private weak var bottomSpaceConstraint: NSLayoutConstraint!

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollContentView: UIView!
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) {
            return .darkContent
        } else {
            return .default
        }
    }
    
    private var keyboardDistanceFromTextField: CGFloat = 0.0
    private let separatorLabelConstraint: CGFloat = 10.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTextField()
        setupTapGestureRecognizer()
        registerObservers()
        setupLabels()
        reloadContent()
    }
    
    override func loadView() {
        super.loadView()
        if let bottomButtonsView = BottomActionsOnboardingView.instantiateFromNib() {
            bottomButtonsView.embedInto(container: self.buttonsView)
            self.buttonsView = bottomButtonsView
        }
    }
    
    override func prepareView() {
        super.prepareView()
        buttonsView.delegate = self
        buttonsView.setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.shared.enableAutoToolbar = false
        self.keyboardDistanceFromTextField = IQKeyboardManager.shared.keyboardDistanceFromTextField
        IQKeyboardManager.shared.keyboardDistanceFromTextField += self.buttonsView.frame.size.height + self.descriptionLabel.frame.size.height + self.separatorLabelConstraint
        self.textField.updateData(text: self.presenter.userName)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared.keyboardDistanceFromTextField = keyboardDistanceFromTextField
    }
    
    override class var storyboardName: String {
        return "Onboarding"
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .changedLanguageApp, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification,
                                                  object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification,
                                                  object: nil)
    }
}

private extension OnboardingChangeAliasViewController {
    
    private var texfieldStyle: LisboaTextFieldStyle {
        var style = LisboaTextFieldStyle.default
        style.titleLabelFont = .santander(family: .text, type: .regular, size: 14)
        style.titleLabelTextColor = .brownishGray
        
        style.fieldFont = .santander(family: .text, type: .regular, size: 20)
        style.fieldTextColor = .lisboaGrayNew
        
        return style
    }
    
    private var textfieldTitle: String { localized(key: "onboarding_label_alias").text }
    
    func setupTextField() {
        textField.configure(with: nil,
                            title: textfieldTitle,
                            style: texfieldStyle,
                            extraInfo: nil)
        textField.field.autocapitalizationType = .none
        textField.field.returnKeyType = .done
        textField.setAllowOnlyCharacters(.alias)
        textField.setMaxCharacters(20)
        textField.accessibilityIdentifier = AccessibilityOnboarding.aliasInput
    }
    
    func setupLabels() {
        titleLabel.applyStyle(LabelStylist(textColor: UIColor.black,
                                           font: UIFont.santanderTextRegular(size: 38),
                                           textAlignment: .left))
        titleLabel.set(lineHeightMultiple: 0.75)
        
        descriptionLabel.applyStyle(LabelStylist(textColor: UIColor.black,
                                                 font: UIFont.santanderTextLight(size: 14),
                                                 textAlignment: .left))
        markLabel.applyStyle(LabelStylist(textColor: UIColor.black,
                                          font: UIFont.santanderTextBold(size: 14),
                                          textAlignment: .left))
        markLabel.text = "*"
    }
    
    func registerObservers() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(reloadContent),
                                               name: .changedLanguageApp,
                                               object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    
    func setupTapGestureRecognizer() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(hiddeKeyboard))
        gesture.cancelsTouchesInView = false
        gesture.delegate = self
        self.view.addGestureRecognizer(gesture)
    }
    
    @objc func hiddeKeyboard() {
        self.view.endEditing(true)
    }
    
    @objc func reloadContent() {
        titleLabel.set(localizedStylableText: localized(key: "onboarding_title_yourName"))
        descriptionLabel.set(localizedStylableText: localized(key: "onboarding_asteriskText_alias"))
        buttonsView.continueText = localized(key: "generic_button_continue")
        buttonsView.backText = localized(key: "generic_button_previous")
        textField.updateTitle(textfieldTitle)
    }
    
    func showToast() {
        Toast.show(localized(key: "generic_alert_notAvailableOperation").text)
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
            let animationTime = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue
            else { return }
        editorWillHide(time: animationTime)
    }
    
    func editorWillShow(height: CGFloat, time: Double) {
        let bottomSafeArea: CGFloat
        if #available(iOS 11.0, *) {
            bottomSafeArea = self.view.safeAreaInsets.bottom
        } else {
            bottomSafeArea = self.bottomLayoutGuide.length
        }
        self.bottomSpaceConstraint.constant = height - bottomSafeArea
        UIView.animate(withDuration: time) {
            self.view.layoutSubviews()
        }
    }
    
    func editorWillHide(time: Double) {
        self.bottomSpaceConstraint.constant = 0
        UIView.animate(withDuration: time) {
            self.view.layoutSubviews()
        }
        scrollView.scrollRectToVisible(scrollContentView.frame, animated: true)
    }
    
    func saveAction() {
        guard let text = textField.text else { return }
        view.endEditing(true)
        if text.isEmpty || text.isBlank {
            textField.updateData(text: presenter.usernameWithoutAlias())
        }
        presenter.continueButtonPressed(newAlias: text.isEmpty || text.isBlank ? presenter.usernameWithoutAlias() ?? "" : text)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
            let keyboardSizeHeight = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size.height,
            let animationTime = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue
            else { return }
        
        editorWillShow(height: keyboardSizeHeight, time: animationTime)
    }
}

extension OnboardingChangeAliasViewController: OnboardingClosableProtocol {}

extension OnboardingChangeAliasViewController: BottomActionsOnboardingViewDelegate {
    func backPressed() {
        presenter.backButttonPressed()
    }
    
    func continuePressed() {
        saveAction()
    }
}

extension OnboardingChangeAliasViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldReceive touch: UITouch) -> Bool {
        return !(touch.view is UIControl)
    }
}

extension OnboardingChangeAliasViewController: OnBoardingStepView {}
