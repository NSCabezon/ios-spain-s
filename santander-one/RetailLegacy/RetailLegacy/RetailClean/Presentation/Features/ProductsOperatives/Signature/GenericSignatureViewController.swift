import UIKit
import IQKeyboardManagerSwift
import Operative
import CoreFoundationLib
import UI
import CoreDomain

let genericSignatureStoryboardName = "ProductOperatives"
let alphaNumRegex = "^[a-zA-Z0-9]+$"

protocol GenericSignaturePresenterProtocol: OperativeStepPresenterProtocol {
    var styledTitle: LocalizedStylableText { get }
    var signature: SignatureRepresentable? { get }
    var navigationBarTitle: String? { get }
    var showsHelpButton: Bool { get }
    func validateCharacter(_ text: String) -> Bool
    func validPositionsArray(_ values: SignatureRepresentable)
    func didSelectHelp()
    func didSelectHelpNavBar()
    func didTapBack()
    func didTapClose()
    func trackFaqEvent(_ question: String, url: URL?)
}

final class GenericSignatureViewController: BaseViewController<GenericSignaturePresenterProtocol> {
    @IBOutlet private var numberField: [GenericSignatureTextField]!
    @IBOutlet private var titleSignature: UILabel!
    @IBOutlet private var positionsLabels: UILabel!
    @IBOutlet private var helpButton: UIButton!
    @IBOutlet private var acceptButton: UIButton!
    
    @IBOutlet private weak var bottomSeparator: UIView!
    @IBOutlet private var bottomMarginAcceptButton: NSLayoutConstraint!
    
    private var isDisableFields: Bool = false
    private var viewIsVisible: Bool = true
    private var keyboardType: UIKeyboardType = .default
    
    private var isVisible: Bool {
        return viewIsVisible && presentedViewController == nil
    }
    
    override class var storyboardName: String {
        return genericSignatureStoryboardName
    }
    
    override var progressBarBackgroundColor: UIColor? {
        return .uiWhite
    }
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupAccessibility()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.backgroundColor = .uiBackground
        viewIsVisible = true
        if !UIAccessibility.isVoiceOverRunning {
            setupNavigationBar()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !UIAccessibility.isVoiceOverRunning {
            numberField.becomeFirstResponder()
        }
        IQKeyboardManager.shared.enableAutoToolbar = false
        isEditing = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewIsVisible = false
        self.endEditing(true)
    }
    
    override func endEditing(_ force: Bool) {
        isEditing = false
        self.view.endEditing(force)
    }
    
    // MARK: Actions
    @IBAction func sendSignatureButtonAction(_ sender: Any) {
        guard var signature = presenter.signature else { return }
        signature.values = numberField.enabled(empty: false).compactMap { $0.textSignature }
        presenter.validPositionsArray(signature)
    }
    
    @IBAction func helpAction(_ sender: UIButton) {
        self.presenter.didSelectHelp()
    }
}

// MARK: "View Delegate"
///Spoiler, it's not really a delegate, but the presenter calls it.

extension GenericSignatureViewController {
    func activateInteractionUser(_ activate: Bool) {
        self.view.isUserInteractionEnabled = activate
    }
    
    func resetNumberTextFields() {
        guard
            let positions = presenter.signature?.positions,
            let length = presenter.signature?.length
        else { return }
        for index in length..<numberField.count { hideTextField(at: index) }
        for textfieldIndex in 1...length {
            var fixedIndex: Int = textfieldIndex
            fixedIndex -= 1
            positions.contains(textfieldIndex)
            ? setupEnableTextFields(at: fixedIndex)
            : setupDisableTextFields(at: fixedIndex)
        }
    }
    
    func showFaqs(_ items: [FaqsItemViewModel]) {
        let data = FaqsViewData(items: items)
        data.show(in: self)
    }
}

// MARK: Private functions

private extension GenericSignatureViewController {
    // MARK: Text field accessors
    var isSignatureFilled: Bool {
        return numberField.contains(where: { $0.isEnabled == true && $0.text?.isEmpty == true })
    }
    
    // MARK: Setup
    func setupViews() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        styledTitle = presenter.styledTitle
        
        guard let positions = presenter.signature?.positions else { return }
        setupPositionLabel(with: positions)
        titleSignature.applyStyle(LabelStylist(textColor: .sanRed, font: UIFont.latoSemibold(size: 22), textAlignment: .center))
        titleSignature.set(localizedStylableText: stringLoader.getString("signing_text_key"))
        positionsLabels.applyStyle(LabelStylist(textColor: .uiBlack, font: UIFont.latoLight(size: 19), textAlignment: .center))
        helpButton.applyStyle(ButtonStylist(textColor: .sanRed,
                                            font: UIFont.santanderTextRegular(size: 15),
                                            borderColor: nil, borderWidth: nil,
                                            backgroundColor: nil))
        helpButton.set(localizedStylableText: stringLoader.getString("signing_text_remember"), state: .normal)
        helpButton.labelButtonLines(numberOfLines: 2)
        helpButton.titleLabel?.textAlignment = .center
        acceptButton.applyStyle(ButtonStylist.genericSignatureAcceptButton)
        acceptButton.layer.cornerRadius = 20
        acceptButton.set(localizedStylableText: stringLoader.getString("signing_button_sign"), state: .normal)
        disableAcceptButton()
        bottomSeparator.backgroundColor = .lisboaGray
        resetNumberTextFields()
        self.setAccessibilityIdentifiers()
    }
    
    func setAccessibilityIdentifiers() {
        for (index, element) in numberField.enumerated() {
            element.accessibilityIdentifier = AccessibilityOtherOperatives.txtSignature.rawValue + "_" + String(index)
        }
        titleSignature.accessibilityIdentifier = AccessibilityOtherOperatives.lblSignatureTitle.rawValue
        positionsLabels.accessibilityIdentifier = AccessibilityOtherOperatives.lblSignatureDescription.rawValue
        helpButton.accessibilityIdentifier = AccessibilityOtherOperatives.btnSignatureRemember.rawValue
        helpButton.titleLabel?.accessibilityIdentifier = AccessibilityOtherOperatives.btnSignatureRememberLabel.rawValue
        acceptButton.accessibilityIdentifier = AccessibilityOtherOperatives.btnSignature.rawValue
        acceptButton.titleLabel?.accessibilityIdentifier = AccessibilityOtherOperatives.btnSignatureLabel.rawValue
    }
    
    func setupAccessibility() {
        setupNavigationBar()
        self.accessibilityElements = {
            guard let navigationController = self.navigationController else { return nil }
            var elements: [Any] = []
            if let navigationBarElements = navigationController.navigationBar.accessibilityElements {
                elements.append(contentsOf: navigationBarElements)
            }
            if let progress = navigationController.view.subviews.first(where: { $0 is LisboaProgressView }) {
                elements.append(progress)
            }
            elements.append(contentsOf: [titleSignature!, positionsLabels!])
            elements.append(contentsOf: numberField.enabled(empty: true))
            elements.append(contentsOf: [helpButton!, acceptButton!])
            return elements
        }()
    }
    
    func setupNavigationBar() {
        var navigationBarBuilder: NavigationBarBuilder
        if let headerKey = presenter.navigationBarTitle {
            navigationBarBuilder = NavigationBarBuilder(
                style: .custom(background: .color(.uiWhite), tintColor: .santanderRed),
                title: .titleWithHeader(titleKey: "toolbar_title_signing",
                                        header: .title(key: headerKey, style: .default)))
        } else {
            navigationBarBuilder = NavigationBarBuilder(
                style: .custom(background: .color(.uiWhite), tintColor: .santanderRed),
                title: .title(key: "toolbar_title_signing"))
        }
        navigationBarBuilder.setLeftAction(.back(action: #selector(back)))
        if self.presenter.showsHelpButton {
            navigationBarBuilder.setRightActions(.close(action: #selector(close)), .help(action: #selector(help)) )
        } else {
            navigationBarBuilder.setRightActions(.close(action: #selector(close)))
        }
        navigationBarBuilder.build(on: self, with: nil)
    }
    
    func setupDisableTextFields(at index: Int) {
        guard
            index >= numberField.startIndex,
            index < numberField.endIndex
        else { return }
        numberField[index].text = "*"
        numberField[index].backgroundColor = .uiBackground
        numberField[index].textColor = .sanGreyDark
        numberField[index].isAccessibilityElement = false
    }
    
    func setupEnableTextFields(at index: Int) {
        guard
            index >= numberField.startIndex,
            index < numberField.endIndex
        else { return }
        numberField[index].text = ""
        numberField[index].isEnabled = true
        numberField[index].textColor = .sanRed
        numberField[index].textFieldDelegate = self
        numberField[index].backgroundColor = .uiWhite
        numberField[index].isAccessibilityElement = true
        numberField[index].accessibilityLabel = CoreFoundationLib.localized(
            "siri_voiceover_keyPosition",
            [
                StringPlaceholder(.number, String(index + 1))
            ]
        ).text
    }
    
    func setupPositionLabel(with positions: [Int]) {
        var placeholderArr = [StringPlaceholder]()
        placeholderArr = positions.map { StringPlaceholder(.number, "\($0)") }
        positionsLabels.set(localizedStylableText: stringLoader.getString("signing_text_insertNumbers", placeholderArr))
    }
    
    func enableAcceptButton() {
        acceptButton.backgroundColor = .sanRed
        acceptButton.isEnabled = true
    }
    
    func disableAcceptButton() {
        acceptButton.backgroundColor = .lisboaGray
        acceptButton.isEnabled = false
    }
    
    func hideTextField(at index: Int) {
        numberField[index].isHidden = true
    }
    
    func add(string: String, toTextfield textField: UITextField) {
        guard let genericField = textField as? GenericSignatureTextField else { return }
        genericField.textSignature = string
        genericField.text = string.replacingOccurrences(of: string, with: "*")
        if self.numberField.enabled(empty: true).isEmpty {
            enableAcceptButton()
        }
    }
    
    // MARK: Keyboard notifications
    
    @objc func keyboardDidShow(_ notification: Notification) {
        isEditing = true
        guard
            let userInfo = notification.userInfo,
            let keyboardSize = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size,
            let window = UIApplication.shared.keyWindow
        else { return }
        
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
    
    @objc func keyboardDidHide(_ notification: Notification) {
        bottomMarginAcceptButton.constant = 0
    }
    
    @objc func back() {
        presenter.didTapBack()
    }
    
    @objc func help() {
        presenter.didSelectHelpNavBar()
    }
    
    @objc func close() {
        self.endEditing(true)
        presenter.didTapClose()
    }
}

extension GenericSignatureViewController: FaqsViewControllerDelegate {
    func didExpandAnswer(question: String) {
        presenter.trackFaqEvent(question, url: nil)
    }
    
    func didTapAnswerLink(question: String, url: URL) {
        presenter.trackFaqEvent(question, url: url)
    }
}

// MARK: - TextField Delegate
extension GenericSignatureViewController: UITextFieldDelegate, GenericSignatureTextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField.text?.count == 0, presenter.validateCharacter(string) == true {
            keyboardType = string.rangeOfCharacter(from: CharacterSet.decimalDigits) != nil ? .numbersAndPunctuation: .default
            add(string: string, toTextfield: textField)
            defer {
                numberField.becomeFirstResponder()
            }
            return false
        } else if string.isBackSpace == true {
            textField.text = string
            if !isSignatureFilled { disableAcceptButton() }
            return true
        } else if
            let count = textField.text?.count,
            count > 0,
            let nextTextField = numberField.enabled(empty: true).first,
            !UIAccessibility.isVoiceOverRunning {
            nextTextField.becomeFirstResponder()
            _ = self.textField(nextTextField, shouldChangeCharactersIn: NSRange(location: 0, length: 1), replacementString: string)
            return false
        } else {
            return false
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.keyboardType = keyboardType
        if numberField.enabled(empty: true).isEmpty == false {
            textField.returnKeyType = .next
        } else {
            textField.returnKeyType = .done
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if numberField.enabled(empty: true).isEmpty == false {
            numberField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        guard !self.numberField.enabled(empty: true).isEmpty else {
            enableAcceptButton()
            return
        }
        guard self.isEditing else { return }
    }
    
    // MARK: - Delete Delegate
    func textFieldDidDelete(with textField: UITextField) {
        guard let lastEnteredTextField = self.numberField.enabled(empty: false).last else { return }
        (textField as? GenericSignatureTextField)?.textSignature = nil
        disableAcceptButton()
        guard !UIAccessibility.isVoiceOverRunning else { return }
        lastEnteredTextField.becomeFirstResponder()
    }
}

extension GenericSignatureViewController: OperativeStepViewProtocol {
    var operativePresenter: OperativeStepPresenterProtocol {
        return presenter
    }
}

private extension Array where Element == GenericSignatureTextField {
    func becomeFirstResponder() {
        guard !UIAccessibility.isVoiceOverRunning else { return }
        self.enabled(empty: true).first?.becomeFirstResponder()
    }
    
    func enabled(empty: Bool) -> [GenericSignatureTextField] {
        return self.filter({ $0.isEnabled && $0.text?.isEmpty == empty })
    }
}
