//
//  SignatureViewController.swift
//  Operative
//
//  Created by Jose Carlos Estela Anguita on 30/12/2019.
//

import UIKit
import UI
import CoreFoundationLib
import IQKeyboardManagerSwift
import CoreDomain

public enum SignaturePurpose: OperativeParameterLegacy {
    case signatureActivation
    case general
}

public protocol SignatureViewProtocol: AnyObject {
    func enableAccept()
    func disableAccept()
    func reset()
}

/// This protocol is needed because we have the SignatureViewProtocol in use in the Target Application
public protocol InternalSignatureViewProtocol: SignaturePresentationDelegate {
    func enableAccept()
    func disableAccept()
    func reset()
    func setPurpose(_ purpose: SignaturePurpose)
    func setNavigationBuilderTitle(_ title: String?)
    func showFaqs(_ items: [FaqsItemViewModel])
    func showDialogForType(_ type: SignatureDialogType)
}

open class SignatureViewController: UIViewController {
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var acceptButtonBottomMargin: NSLayoutConstraint!
    @IBOutlet weak var signatureImage: UIImageView!
    @IBOutlet weak var signatureTitleLabel: UILabel!
    @IBOutlet weak var signatureDescriptionLabel: UILabel!
    @IBOutlet weak var rememberSignatureButton: UIButton!
    @IBOutlet weak var rememberSignatureButtonHeight: NSLayoutConstraint!
    @IBOutlet weak var acceptButton: LisboaButton!
    
    private struct Constants {
        static let acceptButtonBottomMargin: CGFloat = 20.0
    }
    
    private let presenter: SignaturePresenterProtocol
    private var internalPresenter: OperativeStepPresenterProtocol? {
        self.presenter as? OperativeStepPresenterProtocol
    }
    private var textfields: [SignatureTextField] {
        return stackView.arrangedSubviews.compactMap({ $0 as? SignatureTextField })
    }
    public var progressBarBackgroundColor: UIColor {
        return self.presenter.operative?.progressBarBackgroundColor ?? .skyGray
    }
    private var keyboardType: UIKeyboardType = .default
    
    public convenience init(presenter: SignaturePresenterProtocol) {
        self.init(nibName: "Signature", bundle: .module, presenter: presenter)
    }
    
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?,
         presenter: SignaturePresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardDidShow(_:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardDidHide(_:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
        let gesture = UITapGestureRecognizer(target: self,
                                             action: #selector(hideKeyboard))
        gesture.cancelsTouchesInView = false
        self.view.addGestureRecognizer(gesture)
        self.setupView()
        self.presenter.viewDidLoad()
        self.accessibilityElements = {
            var elements: [Any] = []
            if let navigationController = self.navigationController {
                if let navigationBarElements = navigationController.navigationBar.accessibilityElements {
                    elements.append(contentsOf: navigationBarElements)
                }
                if let progress = navigationController.view.subviews.first(where: { $0 is LisboaProgressView }) {
                    elements.append(progress)
                }
            }
            elements.append(contentsOf: [signatureTitleLabel!, signatureDescriptionLabel!])
            elements.append(contentsOf: textfields.enabled(empty: true))
            elements.append(contentsOf: [rememberSignatureButton!, acceptButton!])
            return elements
        }()
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.isEditing = true
        if !UIAccessibility.isVoiceOverRunning {
            self.textfields.becomeFirstResponder()
        }
        self.resetTextFieldsStyle()
        IQKeyboardManager.shared.enableAutoToolbar = false
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.endEditing(true)
    }
    
    func endEditing(_ force: Bool) {
        self.isEditing = false
        self.view.endEditing(force)
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
                       },
                       completion: nil)
    }
    
    @objc func keyboardDidHide(_ notification: Notification) {
        self.acceptButtonBottomMargin.constant = Constants.acceptButtonBottomMargin
        self.view.setNeedsLayout()
        let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber ?? 0.25
        UIView.animate(withDuration: TimeInterval(truncating: duration)) { [weak self] in
            self?.view.layoutIfNeeded()
        }
    }
    
    @objc func acceptButtonSelected() {
        self.textfields.disableTextField()
        self.presenter.didSelectAccept(withValues: self.textfields.enabled(empty: false).compactMap({ $0.signatureText }))
    }
    
    @objc func rememberSignatureButtonSelected() {
        self.presenter.didSelectRememberSignature()
    }
    
    @objc func hideKeyboard() {
        self.endEditing(true)
    }
}

extension SignatureViewController: SignatureViewProtocol {
    
    public func enableAccept() {
        self.signatureImage.image = Assets.image(named: "icnLock")
        self.setupAcceptButton(enabled: true)
    }
    
    public func disableAccept() {
        self.signatureImage.image = Assets.image(named: "icnOpenLock")
        self.setupAcceptButton(enabled: false)
    }
    
    public func reset() {
        for textField in textfields {
            textField.text = ""
            textField.signatureText = ""
        }
        textfields.becomeFirstResponder()
        textfields.enableTextField()
        setupAcceptButton(enabled: false)
    }
    
    public func setPurpose(_ purpose: SignaturePurpose) {
        self.signatureTitleLabel.text = localized(purpose == .signatureActivation ? "signing_text_provisionalKey" : "signing_text_key")
        self.rememberSignatureButton.isHidden = purpose == .signatureActivation
        if purpose == .signatureActivation {
            self.rememberSignatureButtonHeight.constant = 0
        }
        self.rememberSignatureButton.labelButtonLines(numberOfLines: 0)
        self.rememberSignatureButton.setTextAligment(.center, for: .normal)
    }
}

extension SignatureViewController: InternalSignatureViewProtocol {
    public func setNavigationBuilderTitle(_ title: String?) {
        setupNavigationBarWithTitle(title)
    }
    
    public var operativePresenter: OperativeStepPresenterProtocol {
        guard let internalPresenter = self.internalPresenter else { fatalError() }
        return internalPresenter
    }
    
    public func showFaqs(_ items: [FaqsItemViewModel]) {
        let data = FaqsViewData(items: items)
        data.show(in: self)
    }
    
    public func showDialogForType(_ type: SignatureDialogType) {
        switch type {
        case .generic(let dependenciesResolver):
            self.showGenericErrorDialog(withDependenciesResolver: dependenciesResolver)
        case .revoked(let phoneNumber, let action, _):
            self.showRevokedError(phoneNumber: phoneNumber, action: action)
        case .otpUserExcepted(let error, let phoneNumber, let stringLoader):
            self.showOtpUserExcepted(error: error, phoneNumber: phoneNumber, stringLoader: stringLoader)
        case .invalid:
            self.showInvalidError()
        case .otherError(let error, let phoneNumber, let action, let stringLoader):
            self.showOtherError(error: error, phoneNumber: phoneNumber, action: action, stringLoader: stringLoader)
        }
    }
}

extension SignatureViewController: FaqsViewControllerDelegate {
    public func didExpandAnswer(question: String) {
        presenter.trackFaqEvent(question, url: nil)
    }
    
    public func didTapAnswerLink(question: String, url: URL) {
        presenter.trackFaqEvent(question, url: url)
    }
}

private extension SignatureViewController {
    func setupNavigationBarWithTitle(_ title: String?) {
        let navigationBarBuilder: NavigationBarBuilder
        if let headerKey = title {
            navigationBarBuilder =
                NavigationBarBuilder(
                    style: .sky,
                    title: .titleWithHeader(titleKey: "toolbar_title_signing",
                                            header: .title(key: headerKey, style: .default)))
        } else {
            navigationBarBuilder =
                NavigationBarBuilder(
                    style: .sky,
                    title: .title(key: "toolbar_title_signing"))
        }
        if self.presenter.showsHelpButton {
            navigationBarBuilder.setRightActions(.close(action: #selector(close)), .help(action: #selector(help)) )
        } else {
            navigationBarBuilder.setRightActions(.close(action: #selector(close)))
        }
        navigationBarBuilder.build(on: self, with: nil)
        self.view.backgroundColor = UIColor.white
    }
    
    func setupView() {
        self.signatureImage.image = Assets.image(named: "icnOpenLock")
        self.setupAcceptButton(enabled: false)
        self.setupTextFields()
        self.setupTitle()
        self.setupDescription()
        self.setupRememberSignatureButton()
        self.setupAccessibilityIds()
    }
    
    func setupTitle() {
        self.signatureTitleLabel.font = .santander(family: .text, type: .bold, size: 18)
        self.signatureTitleLabel.textColor = .lisboaGray
    }
    
    func setupDescription() {
        self.signatureDescriptionLabel.font = .santander(family: .text, type: .light, size: 18)
        self.signatureDescriptionLabel.textColor = .lisboaGray
        let positions = self.presenter.signature.positions?.map {
            StringPlaceholder(.number, String($0))
        }
        self.signatureDescriptionLabel.configureText(withLocalizedString: localized("signing_text_insertNumbers", positions ?? []))
    }
    
    func setupRememberSignatureButton() {
        self.rememberSignatureButton.setTitleColor(.darkTorquoise, for: .normal)
        self.rememberSignatureButton.addTarget(self, action: #selector(rememberSignatureButtonSelected), for: .touchUpInside)
        self.rememberSignatureButton.setTitle(localized("signing_text_remember"), for: .normal)
        self.rememberSignatureButton.titleLabel?.font = .santander(family: .text, type: .regular, size: 15)
    }
    
    func setupAcceptButton(enabled: Bool) {
        if enabled {
            setupEnabledAcceptButton()
        } else {
            setupDisabledAcceptButton()
        }
        self.acceptButton.addSelectorAction(target: self, #selector(acceptButtonSelected))
        self.acceptButton.setTitle(localized("signing_button_sign"), for: .normal)
    }
    
    func setupDisabledAcceptButton() {
        self.acceptButton.setTitleColor(.santanderRed, for: .normal)
        self.acceptButton.titleLabel?.font = UIFont.santander(family: .text, type: .regular, size: 16)
        self.acceptButton.backgroundNormalColor = .white
        self.acceptButton.backgroundPressedColor = .sky
        self.acceptButton.borderWidth = 1
        self.acceptButton.borderColor = .santanderRed
        self.acceptButton.titleLabel?.textAlignment = .center
        self.acceptButton.isEnabled = false
    }
    
    func setupEnabledAcceptButton() {
        self.acceptButton.setTitleColor(.white, for: .normal)
        self.acceptButton.titleLabel?.font = UIFont.santander(family: .text, type: .bold, size: 16)
        self.acceptButton.backgroundNormalColor = .santanderRed
        self.acceptButton.backgroundPressedColor = .bostonRed
        self.acceptButton.titleLabel?.textAlignment = .center
        self.acceptButton.isEnabled = true
    }
    
    func setupTextFields() {
        guard
            let length = self.presenter.signature.length,
            let positions = self.presenter.signature.positions
        else {
            return
        }
        for index in 0 ..< length {
            let textField: SignatureTextField = {
                let fixedIndex = index + 1
                guard !positions.contains(fixedIndex) else {
                    return self.signatureTextField(style: .editable, index: fixedIndex)
                }
                return self.signatureTextField(style: .disabled, index: fixedIndex)
            }()
            switch index {
            case 0:
                textField.position = .first
            case length - 1:
                textField.position = .last
            default:
                textField.position = .unknown
            }
            self.stackView.addArrangedSubview(textField)
        }
    }
    
    func setupAccessibilityIds() {
        self.signatureImage.accessibilityIdentifier = AccessibilityOtherOperatives.imgSignature.rawValue
        self.signatureTitleLabel.accessibilityIdentifier = AccessibilityOtherOperatives.lblSignatureTitle.rawValue
        self.acceptButton.accessibilityIdentifier = AccessibilityOtherOperatives.btnSignature.rawValue
        self.signatureDescriptionLabel.accessibilityIdentifier = AccessibilityOtherOperatives.lblSignatureDescription.rawValue
        self.rememberSignatureButton.accessibilityIdentifier = AccessibilityOtherOperatives.btnSignatureRemember.rawValue
    }
    
    func signatureTextField(style: SignatureTextField.Style, index: Int) -> SignatureTextField {
        let textField = SignatureTextField(frame: .zero)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.set(style: style)
        textField.accessibilityIdentifier = AccessibilityOtherOperatives.txtSignature.rawValue + "_" + String(index)
        textField.delegate = self
        textField.signatureDelegate = self
        textField.text = ""
        textField.accessibilityLabel = localized(
            "siri_voiceover_keyPosition",
            [
                StringPlaceholder(.number, String(index))
            ]
        ).text
        return textField
    }
    
    func add(string: String, to textField: UITextField) {
        guard let textField = textField as? SignatureTextField else { return }
        textField.signatureText = string
        textField.text = string.replacingOccurrences(of: string, with: "*")
        if self.textfields.enabled(empty: true).isEmpty {
            self.enableAccept()
        }
    }
    
    /// Reset all text field styles
    func resetTextFieldsStyle() {
        self.textfields.forEach { textField in
            if textField.isFirstResponder {
                textField.set(style: .editing)
                signatureImage.image = Assets.image(named: "icnOpenLock")
            } else if textField.isEnabled {
                if textField.signatureText?.isEmpty == false {
                    textField.set(style: .edited)
                } else {
                    textField.set(style: .editable)
                }
            } else {
                textField.set(style: .disabled)
            }
        }
    }
    
    @objc private func help() {
        presenter.didSelectHelp()
    }
    
    @objc private func close() {
        presenter.didTapClose()
    }
    
    func showRevokedError(phoneNumber: String?, action: (() -> Void)?) {
        guard let isEmptyPhone = phoneNumber?.isEmpty else { return }
        let errorDescKey: String
        if isEmptyPhone {
            errorDescKey = "signing_text_popup_blocked_withoutNumber"
        } else {
            errorDescKey = "signing_text_popup_blocked"
        }
        let localizedString: LocalizedStylableText = localized(errorDescKey)
        let acceptButton: LocalizedStylableText = localized("signing_button_call", [StringPlaceholder(.phone, phoneNumber ?? "")])
        self.showDialog(
            title: localized("signing_title_popup_blocked"),
            items: [
                .styledConfiguredText(localizedString, configuration: LocalizedStylableTextConfiguration(font: nil, textStyles: nil, alignment: .center, lineHeightMultiple: nil, lineBreakMode: nil))
            ],
            image: "icnAlertError",
            action: Dialog.Action(title: acceptButton.text, action: {
                action?()
            }),
            isCloseOptionAvailable: false
        )
    }
    
    func showOtpUserExcepted(error: GenericErrorSignatureErrorOutput, phoneNumber: String?, stringLoader: StringLoader) {
        self.showDialog(
            title: nil,
            description: error.getErrorDesc().map(localized),
            phone: phoneNumber,
            action: Dialog.Action(title: localized("generic_button_accept"), action: {}),
            isCloseOptionAvailable: false,
            stringLoader: stringLoader
        )
    }
    
    func showInvalidError() {
        let localizedString: LocalizedStylableText = localized("operative_error_SIGBRO_00003")
        self.showDialog(
            title: localized("signing_title_popup_error"),
            items: [
                .styledConfiguredText(localizedString, configuration: LocalizedStylableTextConfiguration(font: nil, textStyles: nil, alignment: .center, lineHeightMultiple: nil, lineBreakMode: nil))
            ],
            image: "icnAlertExclam",
            action: Dialog.Action(title: localized("generic_button_retry"), action: { [weak self] in
                self?.reset()
            }),
            isCloseOptionAvailable: false
        )
    }
    
    func showOtherError(error: GenericErrorSignatureErrorOutput, phoneNumber: String?, action: (() -> Void)?, stringLoader: StringLoader) {
        self.showFatalErrorDialog(
            title: nil,
            description: error.getErrorDesc().map(localized),
            phone: phoneNumber,
            action: Dialog.Action(title: localized("generic_button_accept"), action: { action?() }),
            isCloseOptionAvailable: false,
            stringLoader: stringLoader
        )
    }
}

extension SignatureViewController: SignatureTextFieldDelegate {
    
    func textFieldDidDelete(_ textField: SignatureTextField) {
        guard let targetTextField = self.textfields.enabled(empty: false).last else {
            return
        }
        self.resetTextFieldsStyle()
        textField.signatureText = nil
        targetTextField.isUserInteractionEnabled = true
        guard !UIAccessibility.isVoiceOverRunning else { return }
        targetTextField.becomeFirstResponder()
    }
}

extension SignatureViewController: UITextFieldDelegate {
    
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        guard let textField = textField as? SignatureTextField else { return }
        textField.keyboardType = self.keyboardType
        self.resetTextFieldsStyle()
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        guard textField is SignatureTextField else { return }
        defer {
            self.resetTextFieldsStyle()
        }
        guard !self.textfields.enabled(empty: true).isEmpty else {
            self.enableAccept()
            return
        }
        if self.isEditing {
            self.textfields.becomeFirstResponder()
        }
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let textField = textField as? SignatureTextField else { return false }
        if textField.text?.count == 0 && self.presenter.validateCharacters(of: string) == true {
            self.keyboardType = string.rangeOfCharacter(from: CharacterSet.decimalDigits) != nil ? .numbersAndPunctuation: .default
            self.add(string: string, to: textField)
            defer {
                textfields.becomeFirstResponder()
            }
            return false
        } else if string.isBackSpace == true {
            textField.text = string
            if !self.textfields.enabled(empty: true).isEmpty {
                self.disableAccept()
            }
            return true
        } else if let count = textField.text?.count, count > 0, let nextTextField = textfields.enabled(empty: true).first, !UIAccessibility.isVoiceOverRunning {
            nextTextField.becomeFirstResponder()
            _ = self.textField(nextTextField, shouldChangeCharactersIn: NSRange(location: 0, length: 1), replacementString: string)
            return false
        } else {
            return false
        }
    }
}

private extension Array where Element == SignatureTextField {
    func becomeFirstResponder() {
        guard !UIAccessibility.isVoiceOverRunning else { return }
        self.enabled(empty: true).first?.becomeFirstResponder()
    }
    
    func enabled(empty: Bool) -> [SignatureTextField] {
        return self.filter({ $0.isEnabled && $0.text?.isEmpty == empty })
    }
    
    func disableTextField() {
        _ = self.compactMap({
            $0.resignFirstResponder()
            $0.isUserInteractionEnabled = false
        })
    }
    
    func enableTextField() {
        _ = self.compactMap({
            $0.isUserInteractionEnabled = true
        })
    }
}
