//
//  PasswordTextField.swift
//
//  Created by alvola on 25/09/2019.
//  Copyright © 2019 alp. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import CoreFoundationLib

public protocol PasswordTextFieldDelegate: AnyObject {
    func enterDidPressed()
}

public final class PasswordTextField: LegacyDesignableView, UITextFieldDelegate, UIGestureRecognizerDelegate {
    
    private enum State {
        case char
        case secure
    }
    
    @IBOutlet public weak var textField: UITextField?
    @IBOutlet public weak var showImageView: UIImageView?
    @IBOutlet public weak var showBackView: UIView?
    
    public weak var delegate: PasswordTextFieldDelegate?
    public var observer: NSObjectProtocol?
    
    private var hiddenText: String = "" {
        didSet {
            if hiddenText.count > maxLength {
                hiddenText = ""
                textField?.text = ""
            }
            updatePassword()
        }
    }
    private var state: State = .secure {
        didSet {
            updatePassword()
        }
    }
    
    private let maxLength: Int = 8
    
    public func introducedPassword() -> String { return hiddenText }
    
    public func setPlaceholder(_ placeholder: String) {
        textField?.attributedPlaceholder = NSAttributedString(string: placeholder,
                                                              attributes: [.foregroundColor: UIColor.Legacy.uiWhite])
    }
    
    public func setText(_ text: String?) { hiddenText = text ?? ""; state = .secure }
    
    public func reset() { hiddenText = "" }
    
    public override func removeFromSuperview() {
        super.removeFromSuperview()
        if let observer = observer { NotificationCenter.default.removeObserver(observer) }
    }
    
    // MARK: - privateMethods
    
    override public func commonInit() {
        super.commonInit()
        
        configureTextField()
        configureShowView()
        
        contentView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(becomeResponder)))
        contentView?.isUserInteractionEnabled = true
        
        observer = NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: textField, queue: OperationQueue.main) { [weak self] (notification) in
            self?.setText((notification.object as? UITextField)?.text)
        }
    }
    
    private func configureTextField() {
        textField?.textColor = UIColor.Legacy.uiWhite
        textField?.font = UIFont.santander(family: .text, type: .regular, size: Screen.isIphone4or5 ? 16.0 : 20.0)
        textField?.textAlignment = .left
        textField?.returnKeyType = .default
        textField?.delegate = self
        textField?.keyboardType = .numberPad
        if #available(iOS 11, *) {
            textField?.textContentType = .password
        }
        textField?.autocapitalizationType = .none
        textField?.autocorrectionType = .no
        textField?.spellCheckingType = .no
        textField?.adjustsFontSizeToFitWidth = true
    }
    
    private func configureShowView() {
        let pressGesture = UILongPressGestureRecognizer(target: self, action: #selector(showButtonDidPressed(_:)))
        pressGesture.minimumPressDuration = 0.0
        showBackView?.addGestureRecognizer(pressGesture)
        showBackView?.isUserInteractionEnabled = true
        showImageView?.image = Assets.image(named: "icnEyeOpen")
    }
    
    @objc public func becomeResponder() { textField?.becomeFirstResponder() }
    
    @objc private func showButtonDidPressed(_ recognizer: UILongPressGestureRecognizer) {
        guard !hiddenText.isEmpty else { return }
        if recognizer.state == .began {
            state = .char
            showImageView?.image = Assets.image(named: "icnEyeClose")
        } else if recognizer.state == .ended {
            state = .secure
            showImageView?.image = Assets.image(named: "icnEyeOpen")
        }
    }
    
    private func updatePassword() {
        let array = Array(hiddenText)
        textField?.text = array.reduce("", { return $0 + (state == .secure ? "•" : String($1)) })
        let correction: CGFloat = Screen.isIphone4or5 ? 4.0 : 0.0
        textField?.font = UIFont.santander(family: .text, type: .regular, size: (array.isEmpty ? 20 - correction : (state == .secure ? 50.0 - correction : 28.0 - correction)))
        
        guard let font = textField?.font else { return }
        let charSpace = (state == .secure ? "•" : "9").size(withAttributes: [NSAttributedString.Key.font: font]).width
        let total = charSpace * CGFloat(maxLength + 1) + 10
        if (textField?.frame.width ?? 0.0) - total > 0.0 {
            textField?.defaultTextAttributes.updateValue((array.isEmpty ? 0.2 : ((textField?.frame.width ?? 0.0) - total) / CGFloat(maxLength - 1)),
                                                         forKey: NSAttributedString.Key.kern)
        }
    }
    
    @objc func doneDidPressed() {
        delegate?.enterDidPressed()
    }
    
    // MARK: - UITextFieldDelegate methods
    
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        IQKeyboardManager.shared.toolbarDoneBarButtonItemText = localized("publicHome_button_enter")
        textField.keyboardToolbar.doneBarButton.setTarget(self, action: #selector(doneDidPressed))
        return true
    }
    
    public func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        IQKeyboardManager.shared.toolbarDoneBarButtonItemText = nil
        return true
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard string != " " else { return false }
        let currentText = hiddenText
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        guard updatedText.count <= maxLength else { return false }
        hiddenText = updatedText
        updatePassword()
        
        return false
    }
}
