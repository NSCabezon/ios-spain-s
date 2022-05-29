//
//  DocumentTextField.swift
//  toTest
//
//  Created by alvola on 25/09/2019.
//  Copyright © 2019 alp. All rights reserved.
//

import UIKit
import CoreFoundationLib

public protocol DocumentTextProtocol: AnyObject {
    func dropDownButtonDidPressed()
}

public final class DocumentTextField: LegacyDesignableView {
    @IBOutlet public weak var textField: UITextField?
    @IBOutlet public weak var loginTypeLabel: UILabel!
    @IBOutlet public weak var loginTypeImageView: UIImageView?
    @IBOutlet public weak var loginTypeBackView: UIView?
    @IBOutlet public weak var loginTypeImageHeight: NSLayoutConstraint?
    public weak var docTextDelegate: DocumentTextProtocol?
    public var loginType: LoginIdentityDocumentType = .nif {
        didSet {
            updateDocumentTextField()
        }
    }
    
    private var maxLenght: Int = 9
    
    weak var delegate: UITextFieldDelegate? { didSet { textField?.delegate = delegate } }
    public var returnAction: (() -> Void)?
    
    public var introducedText: String = "" {
        didSet {
            updateTextField()
        }
    }
    
    public var style: DocumentTextFieldConfiguration = DocumentTextFieldConfiguration.defaultConfig() {
        didSet {
            applyConfiguration()
        }
    }
    
    private var observer: NSObjectProtocol?
    
    public override func removeFromSuperview() {
        super.removeFromSuperview()
        if let observer = observer { NotificationCenter.default.removeObserver(observer) }
    }
    
    public func setPlaceholder(_ placeholder: String) {
        textField?.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [.foregroundColor: style.textColor])
    }
    
    public func setText(_ text: String?) {
        introducedText = text ?? ""
        textField?.text = introducedText
    }
    
    public func introducedDocument() -> String { return introducedText }
    
    public func setReturnAction(_ action: @escaping (() -> Void)) { returnAction = action }
    
    public func reset() { introducedText = "" }
    
    // MARK: - privateMethods
    
    override public func commonInit() {
        super.commonInit()
        configureTextField()
        configureInfoImage()
        configureLoginTypeLabel()
        observer = NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: textField, queue: OperationQueue.main) { [weak self] (notification) in
            self?.setText((notification.object as? UITextField)?.text)
        }
    }
    
    @objc private func textDidEdited() { introducedText = textField?.text ?? "" }
    
    private func checkTextLenght() {
        if introducedText.count > maxLenght {
            introducedText = String(introducedText.prefix(maxLenght))
            textField?.text = introducedText
        }
    }
    
    private func configureTextAttributes() {
        let correction: CGFloat = Screen.isIphone4or5 ? 4.0 : 0.0
        textField?.font = UIFont.santander(family: .text, type: .regular, size: style.fontSize - correction)
        textField?.subviews.forEach({ ($0 as? UILabel)?.adjustsFontSizeToFitWidth = true })
        guard let font = textField?.font else { return }
        let currentMaxSpace = introducedText.reduce(CGFloat(0.0), {
            return $0 + String($1).size(withAttributes: [NSAttributedString.Key.font: font]).width
        })
        
        let charSpace = currentMaxSpace > 0 ? (currentMaxSpace / CGFloat(introducedText.count)) : ("9".size(withAttributes: [NSAttributedString.Key.font: font]).width)
        let total = (charSpace * CGFloat(maxLenght + 1)) + 10
        if (textField?.frame.width ?? 0.0) - total > 0.0 {
            textField?.defaultTextAttributes.updateValue((introducedText.isEmpty ? 0.2 : ((textField?.frame.width ?? 0.0) - total) / CGFloat(maxLenght - 1)),
                                                         forKey: NSAttributedString.Key.kern)
        } else {
            textField?.defaultTextAttributes.updateValue(0.2, forKey: NSAttributedString.Key.kern)
        }
    }
    
    private func updateTextField() {
        checkTextLenght()
        if !introducedText.isEmpty && style.adjustFontToFill {
            configureTextAttributes()
        } else {
            textField?.font = UIFont.santander(size: style.placeholderFontSize)
        }
    }
    
    private func configureTextField() {
        textField?.textColor = style.textColor
        textField?.font = UIFont.santander(size: Screen.isIphone4or5 ? style.placeholderFontSize - 4.0 : style.placeholderFontSize)
        textField?.adjustsFontSizeToFitWidth = true
        textField?.minimumFontSize = 8.0
        textField?.returnKeyType = .next
        textField?.keyboardType = .default
        textField?.autocapitalizationType = .none
        textField?.autocorrectionType = .no
        textField?.spellCheckingType = .no
        textField?.delegate = self
        if #available(iOS 11, *) {
            textField?.textContentType = .username
        }
    }
    
    private func applyConfiguration() {
        textField?.textColor = style.textColor
        textField?.font = UIFont.santander(size: Screen.isIphone4or5 ? style.placeholderFontSize - 4.0 : style.placeholderFontSize)
        loginTypeLabel.textColor = style.labelColor
        loginTypeLabel.font = UIFont.santander(size: style.labelFontSize)
        loginTypeImageHeight?.constant = style.iconHeight
        if style.withShadow {
            self.drawRoundedBorderAndShadow(with: ShadowConfiguration(color: .lightSanGray,
                                                                      opacity: 0.5,
                                                                      radius: 4.0,
                                                                      withOffset: 0.0,
                                                                      heightOffset: 2.0),
                                            cornerRadius: 8.0,
                                            borderColor: .mediumSkyGray,
                                            borderWith: 1.0)
        }
        
        backgroundColor = style.backgroundColor
        loginTypeImageView?.image = Assets.image(named: style.iconDown)
    }
    
    private func configureInfoImage() {
        loginTypeBackView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dropDownButtonDidPressed)))
        loginTypeBackView?.isUserInteractionEnabled = true
        loginTypeImageView?.image = Assets.image(named: style.iconDown)
    }
    
    private func configureLoginTypeLabel() {
        loginTypeLabel.textColor = style.labelColor
        loginTypeLabel.font = UIFont.santander(size: style.labelFontSize)
        let localizedKey = LoginIdentityDocumentType.nif.stringValue
        loginTypeLabel.text = localized(localizedKey)
    }
    
    public func setDocumentTextField(type: LoginIdentityDocumentType, isDropDownPresent: Bool) {
        loginTypeImageView?.image = Assets.image(named: (isDropDownPresent ? style.iconUp : style.iconDown))
        loginTypeLabel.text = localized(type.stringValue)
    }
    
    public func setLoginType(_ type: LoginIdentityDocumentType) {
        self.loginType = type
    }
    
    private func setTextFieldMaxLenght() {
        let isUser = loginType == .user
        maxLenght = isUser ? 20 : 9
    }
    
    private func updateDocumentTextField() {
        setTextFieldMaxLenght()
        updateTextField()
    }
    
    @objc private func dropDownButtonDidPressed() {
        self.docTextDelegate?.dropDownButtonDidPressed()
    }
    
    @objc private func becomeResponder() { textField?.becomeFirstResponder() }

}

// MARK: - UITextFieldDelegate methods
extension DocumentTextField: UITextFieldDelegate {
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        returnAction?()
        return true
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard string != " " else { return false }
        let currentText = introducedText
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        guard updatedText.count <= maxLenght else { return false }
        introducedText = updatedText
        
        return true
    }
}

public struct DocumentTextFieldConfiguration {
    let backgroundColor: UIColor
    let textColor: UIColor
    let placeholderFontSize: CGFloat
    let fontSize: CGFloat
    let labelColor: UIColor
    let labelFontSize: CGFloat
    let withShadow: Bool
    let iconUp: String
    let iconDown: String
    let adjustFontToFill: Bool
    let iconHeight: CGFloat
    
    public static func defaultConfig() -> DocumentTextFieldConfiguration {
        return DocumentTextFieldConfiguration(backgroundColor: .clear,
                                              textColor: .white,
                                              placeholderFontSize: 20.0,
                                              fontSize: 28.0,
                                              labelColor: .white,
                                              labelFontSize: 12.0,
                                              withShadow: false,
                                              iconUp: "icnUpWhite",
                                              iconDown: "icnDownWhite",
                                              adjustFontToFill: true,
                                              iconHeight: 32.0)
    }
    
    public static func whiteConfig() -> DocumentTextFieldConfiguration {
        return DocumentTextFieldConfiguration(backgroundColor: .white,
                                              textColor: .lisboaGray,
                                              placeholderFontSize: 18.0,
                                              fontSize: 18.0,
                                              labelColor: .lisboaGray,
                                              labelFontSize: 10.0,
                                              withShadow: true,
                                              iconUp: "icnArrowUpGreen",
                                              iconDown: "icnDownGreen",
                                              adjustFontToFill: false,
                                              iconHeight: 24.0)
    }
}
