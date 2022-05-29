//
//  DocumentPTTextField.swift
//  UI
//
//  Created by David Gálvez Alonso on 28/12/2020.
//

import UIKit
import CoreFoundationLib

public final class DocumentPTTextField: LegacyDesignableView, AnimationTextFieldProtocol {
    @IBOutlet public weak var textField: ConfigurableActionsTextField!
    @IBOutlet public weak var titleLabel: UILabel!
    @IBOutlet public var centerConstraint: NSLayoutConstraint!
    @IBOutlet public var bottomConstraint: NSLayoutConstraint!
    
    private var maxLenght: Int = 64
    
    private weak var delegate: UITextFieldDelegate? { didSet { textField.delegate = delegate } }
    private var returnAction: (() -> Void)?
    
    public var introducedText: String = "" {
        didSet {
            updateTextField()
        }
    }
    
    private var observer: NSObjectProtocol?
    
    public override func removeFromSuperview() {
        super.removeFromSuperview()
        if let observer = observer { NotificationCenter.default.removeObserver(observer) }
    }

    public func setText(_ text: String?) {
        introducedText = text ?? ""
        textField.text = introducedText
    }
    
    public func introducedDocument() -> String {
        return introducedText
    }
    
    public func setReturnAction(_ action: @escaping (() -> Void)) {
        returnAction = action
    }
    
    public func reset() {
        introducedText = ""
    }
        
    override public func commonInit() {
        super.commonInit()
        configureTextField()
        configureLoginTypeLabel()
        configureView()
    }
    
}

// MARK: - Private methods

private extension DocumentPTTextField {
    @objc func textDidEdited() {
        introducedText = textField.text ?? ""
    }
    
    @objc func becomeResponder() {
        textField.becomeFirstResponder()
    }

    func checkTextLenght() {
        if introducedText.count > maxLenght {
            introducedText = String(introducedText.prefix(maxLenght))
            textField.text = introducedText
        }
    }
    
    func configureTextAttributes() {
        let correction: CGFloat = Screen.isIphone4or5 ? 4.0 : 0.0
        textField.font = UIFont.santander(family: .text, type: .regular, size: 20.0 - correction)
        textField.subviews.forEach({ ($0 as? UILabel)?.adjustsFontSizeToFitWidth = true })
    }
    
    func updateTextField() {
        checkTextLenght()
        if !introducedText.isEmpty {
            configureTextAttributes()
        } else {
            textField.font = UIFont.santander(family: .text, type: .regular, size: 20)
        }
        self.changeFieldVisibility(isFieldVisible: true, animated: false)
    }
    
    func configureTextField() {
        textField.textColor = UIColor.Legacy.uiWhite
        textField.font = UIFont.santander(family: .text, type: .regular, size: Screen.isIphone4or5 ? 16.0 : 20.0)
        textField.adjustsFontSizeToFitWidth = true
        textField.minimumFontSize = 12.0
        textField.returnKeyType = .next
        textField.keyboardType = .default
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.spellCheckingType = .no
        textField.delegate = self
        if #available(iOS 11, *) {
            textField.textContentType = .username
        }
        self.changeFieldVisibility(isFieldVisible: false, animated: false)
    }
    
    func configureLoginTypeLabel() {
        titleLabel.textColor = .white
        titleLabel.text = localized("login_select_user").text
    }
    
    func configureView() {
        contentView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(becomeResponder)))
        contentView?.isUserInteractionEnabled = true
        observer = NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: textField, queue: OperationQueue.main) { [weak self] (notification) in
            self?.setText((notification.object as? UITextField)?.text)
        }
    }
}

// MARK: - UITextFieldDelegate methods
extension DocumentPTTextField: UITextFieldDelegate {
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        returnAction?()
        return true
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = introducedText
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        if updatedText.count > self.maxLenght {
            let changeUpdatedText = updatedText.substring(0, self.maxLenght) ?? ""
            introducedText = changeUpdatedText
            textField.text = changeUpdatedText
            return false
        } else {
            introducedText = updatedText
            return true
        }
    }
    
    public func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        self.changeFieldVisibility(isFieldVisible: textField.text?.isEmpty == false, animated: true)
        return true
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        self.changeFieldVisibility(isFieldVisible: textField.text?.isEmpty == false, animated: true)
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        self.changeFieldVisibility(isFieldVisible: textField.text?.isEmpty == false, animated: true)
    }

    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        self.changeFieldVisibility(isFieldVisible: true, animated: true)
        return true
    }
}
