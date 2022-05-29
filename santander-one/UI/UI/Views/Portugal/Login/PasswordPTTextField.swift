//
//  PasswordPTTextField.swift
//  Pods
//
//  Created by David Gálvez Alonso on 28/12/2020.
//

import UIKit
import IQKeyboardManagerSwift
import CoreFoundationLib

public protocol PasswordPTTextFieldDelegate: AnyObject {
    func enterDidPressed()
}

public final class PasswordPTTextField: LegacyDesignableView, UIGestureRecognizerDelegate, AnimationTextFieldProtocol {
    
    @IBOutlet public weak var titleLabel: UILabel!
    @IBOutlet public weak var textField: ConfigurableActionsTextField!
    @IBOutlet public weak var showImageView: UIImageView!
    @IBOutlet public weak var showBackView: UIView!
    @IBOutlet public var centerConstraint: NSLayoutConstraint!
    @IBOutlet public var bottomConstraint: NSLayoutConstraint!
    
    public weak var delegate: PasswordPTTextFieldDelegate?
    public var observer: NSObjectProtocol?
    public var customValidatorDelegate: TextFieldValidatorProtocol?
    
    private var hiddenText: String = "" {
        didSet {
            if hiddenText.count > maxLength {
                hiddenText = ""
                textField.text = ""
            }
            updatePassword()
        }
    }
    
    private var state: State = .secure {
        didSet {
            updatePassword()
        }
    }
    
    private let maxLength: Int = 30
    
    public func introducedPassword() -> String {
        return hiddenText
    }
    
    public func setText(_ text: String?) {
        hiddenText = text ?? ""
        state = .secure
    }
    
    public func reset() {
        hiddenText = ""
        self.changeFieldVisibility(isFieldVisible: textField.text?.isEmpty == false, animated: true)
    }
    
    public override func removeFromSuperview() {
        super.removeFromSuperview()
        if let observer = observer { NotificationCenter.default.removeObserver(observer) }
        textField.keyboardType = .default
    }
        
    override public func commonInit() {
        super.commonInit()
        configureView()
        configureTextField()
        configureShowView()
        configureTitleLabel()
       
    }
    
    @objc public func becomeResponder() {
        textField.becomeFirstResponder()
    }
}

// MARK: - Private methods

private extension PasswordPTTextField {
    
    func configureTextField() {
        textField.textColor = UIColor.Legacy.uiWhite
        textField.font = UIFont.santander(family: .text, type: .regular, size: Screen.isIphone4or5 ? 16.0 : 20.0)
        textField.textAlignment = .left
        textField.returnKeyType = .default
        textField.delegate = self
        textField.keyboardType = .asciiCapable
        if #available(iOS 11, *) {
            textField.textContentType = .password
        }
        textField.setDisabledActions(TextFieldActions.keyDisabledActions)
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.spellCheckingType = .no
        textField.adjustsFontSizeToFitWidth = true
        IQKeyboardManager.shared.toolbarDoneBarButtonItemText = localized("publicHome_button_enter")
        textField.keyboardToolbar.doneBarButton.setTarget(self, action: #selector(doneDidPressed))
    }
    
    func configureShowView() {
        let pressGesture = UITapGestureRecognizer(target: self, action: #selector(showButtonDidPressed(_:)))
        showBackView.addGestureRecognizer(pressGesture)
        showBackView.isUserInteractionEnabled = true
        showImageView.image = Assets.image(named: "icnEyeOpen")
        showBackView.accessibilityLabel = localized("voiceover_showPassword")
    }
    
    func configureView() {
        contentView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(becomeResponder)))
        contentView?.isUserInteractionEnabled = true
        observer = NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: textField, queue: OperationQueue.main) { [weak self] (notification) in
            self?.setText((notification.object as? UITextField)?.text)
        }
    }
    
    func configureTitleLabel() {
        titleLabel.textColor = .white
        titleLabel.text = localized("login_hint_password").text
        titleLabel.font = UIFont.santander(family: .text, type: .regular, size: Screen.isIphone4or5 ? 16.0 : 20.0)
    }
    
    @objc func showButtonDidPressed(_ recognizer: UITapGestureRecognizer) {
        guard !hiddenText.isEmpty else { return }
        if recognizer.state == .ended && self.state == .secure {
            state = .char
            showImageView.image = Assets.image(named: "icnEyeClose")
            showBackView.accessibilityLabel = localized("voiceover_hidePassword")
        } else {
            state = .secure
            showImageView.image = Assets.image(named: "icnEyeOpen")
            showBackView.accessibilityLabel = localized("voiceover_showPassword")
        }
    }
    
    func updatePassword() {
        let array = Array(hiddenText)
        textField.text = array.reduce("", { return $0 + (state == .secure ? "•" : String($1)) })
        let correction: CGFloat = Screen.isIphone4or5 ? 4.0 : 0.0
        textField.font = UIFont.santander(family: .text, type: .regular, size: (array.isEmpty ? 20 - correction : (state == .secure ? 50.0 - correction : 20.0 - correction)))
        guard let font = textField.font else { return }
        let charSpace = (state == .secure ? "•" : "9").size(withAttributes: [NSAttributedString.Key.font: font]).width
        let total = charSpace * CGFloat(maxLength + 1) + 10
        if textField.frame.width - total > 0.0 {
            textField.defaultTextAttributes.updateValue((array.isEmpty ? 0.2 : (textField.frame.width - total) / CGFloat(maxLength - 1)),
                                                         forKey: NSAttributedString.Key.kern)
        }
    }
    
    @objc func doneDidPressed() {
        delegate?.enterDidPressed()
    }
    
    enum State {
        case char
        case secure
    }
}

// MARK: - UITextFieldDelegate methods

extension PasswordPTTextField: UITextFieldDelegate {

    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }

    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard string != " " else { return false }
        if  let emojiDelegate = customValidatorDelegate, emojiDelegate.isEmoji(string) {
            return false }
        let currentText = hiddenText
        guard let stringRange = Range(range, in: currentText) else { return false }
        var updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        if updatedText.count > self.maxLength {
            updatedText = updatedText.substring(0, self.maxLength) ?? ""
        }
        hiddenText = updatedText
        updatePassword()
        self.changeFieldVisibility(isFieldVisible: textField.text?.isEmpty == false, animated: true)
        if string == "" {
            let currentPosition: Int = range.location
            if let newPosition = textField.position(from: textField.beginningOfDocument, offset: currentPosition) {
                textField.selectedTextRange = textField.textRange(from: newPosition, to: newPosition)
            }
        } else {
            let currentPosition: Int = range.location
            if let newPosition = textField.position(from: textField.beginningOfDocument, offset: currentPosition+1) {
                textField.selectedTextRange = textField.textRange(from: newPosition, to: newPosition)
                }
        }
        return false
    }
    
    public func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        IQKeyboardManager.shared.toolbarDoneBarButtonItemText = nil
        return true
    }
    
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        self.changeFieldVisibility(isFieldVisible: true, animated: true)
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        self.changeFieldVisibility(isFieldVisible: textField.text?.isEmpty == false, animated: true)
    }
}
