//
//  FloatingTitleLisboaTextField.swift
//  UI
//
//  Created by José Carlos Estela Anguita on 27/05/2020.
//

import CoreFoundationLib

public protocol FloatingTitleLisboaTextFieldDelegate: AnyObject {
    func textFieldDidBeginEditing(_ textField: UITextField)
    func textFieldDidEndEditing(_ textField: UITextField)
}

final class FloatingTitleLisboaTextField: XibView {
    // MARK: - Outlets
    @IBOutlet weak var textField: ConfigurableActionsTextField!
    @IBOutlet weak var mainStackView: UIStackView!
    @IBOutlet weak var bottomBorderView: UIView!
    @IBOutlet private weak var overTextFieldButton: UIButton!
    @IBOutlet private weak var placeholderLabel: UILabel!
    @IBOutlet private var placeholderLabelCenterConstraint: NSLayoutConstraint!
    @IBOutlet private var placeholderLabelBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var textFieldHeight: NSLayoutConstraint!
    @IBOutlet private weak var containerView: UIView!
    
    // MARK: - Attributes

    var text: String? {
        didSet {
            self.textField.text = self.text
            let isEmptyField = self.isEmptyField(with: self.textField)
            self.changeTextFieldVisibility(isVisible: !isEmptyField, animated: true)
        }
    }
    var placeholder: String? {
        didSet {
            self.placeholderLabel.text = self.placeholder
        }
    }
    var textFieldPlaceholder: String? {
        didSet {
            self.textField.placeholder = textFieldPlaceholder
        }
    }
    var style: LisboaTextFieldStyle = .default {
        didSet {
            updateStyle()
        }
    }
    var fieldDelegate: UITextFieldDelegate? {
        didSet {
            self.textField.delegate = self.fieldDelegate
        }
    }
    var adjustTextSize: LisboaTextField.TextScaleType = .none {
        didSet {
            self.setTextSize()
        }
    }
    weak var updatableDelegate: UpdatableTextFieldDelegate?
    weak var lisboaTextFieldDelegate: FloatingTitleLisboaTextFieldDelegate?
    var fieldValue: String?
    private var keyboardReturnAction: (() -> Void)?
    private var textfieldCustomizationBlock: ((LisboaTextField.CustomizableComponents) -> Void)?
    private var availableCharacterSet: CharacterSet?
    private let expandedHeight: CGFloat = 24
    
    // MARK: - Private
    
    @objc private func didSelectOverTextFieldButton() {
        self.changeTextFieldVisibility(isVisible: true, animated: true)
        self.textField.becomeFirstResponder()
    }
    
    // MARK: - Public
    
    func setReturnAction(_ action: (() -> Void)?) {
        self.keyboardReturnAction = action
    }
    
    func setCustomizationBlock(_ block: ((LisboaTextField.CustomizableComponents) -> Void)?) {
        self.textfieldCustomizationBlock = block
    }
}

private extension FloatingTitleLisboaTextField {
    
    func changeTextFieldVisibility(isVisible: Bool, animated: Bool) {
        self.overTextFieldButton.isHidden = isVisible
        self.placeholderLabel.font = isVisible ? self.style.visibleTitleLabelFont : self.style.titleLabelFont
        self.textField.isHidden = !isVisible
        self.textFieldHeight.constant = isVisible ? self.expandedHeight: 0
        self.placeholderLabelCenterConstraint.isActive = !isVisible
        self.placeholderLabelBottomConstraint.isActive = isVisible
        if animated {
            UIView.animate(
                withDuration: 0.5,
                delay: 0.0,
                usingSpringWithDamping: 0.9,
                initialSpringVelocity: 1,
                options: [],
                animations: {
                    self.layoutIfNeeded()
                },
                completion: nil
            )
        } else {
            self.layoutIfNeeded()
        }
    }
    
    func isEmptyField(with textField: UITextField) -> Bool {
        let text = textField.text ?? ""
        let placeholder = textField.placeholder ?? ""
        return text.isEmpty && placeholder.isEmpty
    }
    
    func setTextSize() {
        switch self.adjustTextSize {
        case .none:
            break
        case .minimumFontSize(size: let fontSize):
            self.textField.adjustsFontSizeToFitWidth = true
            self.textField.minimumFontSize = fontSize
        case .noMinimumSize:
            self.textField.adjustsFontSizeToFitWidth = true
        case .percentage(percent: let percent):
            self.textField.adjustsFontSizeToFitWidth = true
            let minimumFontSize = (self.style.fieldFont.pointSize * percent) / 100
            self.textField.minimumFontSize = minimumFontSize
        }
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        self.fieldValue = textField.text
        self.updatableDelegate?.updatableTextFieldDidUpdate()
    }
}

extension FloatingTitleLisboaTextField: CustomizableTextFieldProtocol {
    
    func setRightViewOffset(_ offset: (x: CGFloat, y: CGFloat)) {
        self.textField.rightViewOffset = offset
    }
}

extension FloatingTitleLisboaTextField: TextFieldDelegateConfigurable {}

extension FloatingTitleLisboaTextField: LisboaTextFieldViewProtocol, LisboaTextFieldStyleProtocol {
    func setup() {
        self.overTextFieldButton.addTarget(self, action: #selector(didSelectOverTextFieldButton), for: .touchUpInside)
        self.updateStyle()
        self.overTextFieldButton.backgroundColor = .clear
        self.overTextFieldButton.setTitle("", for: .normal)
        self.changeTextFieldVisibility(isVisible: false, animated: false)
        self.textfieldCustomizationBlock?(LisboaTextField.CustomizableComponents(textField: self.textField, floatingLabel: self.placeholderLabel))
        self.textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }

    func updateStyle() {
        self.backgroundColor = self.style.backgroundColor
        self.placeholderLabel.font = self.style.titleLabelFont
        self.placeholderLabel.textColor = self.style.titleLabelTextColor
        self.containerView.backgroundColor = self.style.containerViewBackgroundColor
        self.containerView.layer.borderColor = self.style.containerViewBorderColor
        self.containerView.layer.borderWidth = self.style.containerViewBorderWidth
        self.textField.backgroundColor = self.style.fieldBackgroundColor
        self.textField.tintColor = self.style.fieldTintColor
        self.textField.textColor = self.style.fieldTextColor
        self.textField.font = self.style.fieldFont
        self.bottomBorderView.backgroundColor = self.style.verticalSeparatorBackgroundColor
    }

    func updateStyleIfNeed() {
        let isEmptyField = self.isEmptyField(with: textField)
        self.changeTextFieldVisibility(isVisible: !isEmptyField, animated: true)
    }
}

extension FloatingTitleLisboaTextField: UITextFieldDelegate {

    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.lisboaTextFieldDelegate?.textFieldDidBeginEditing(textField)
    }
    
    public func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        let isEmptyField = self.isEmptyField(with: textField)
        self.changeTextFieldVisibility(isVisible: !isEmptyField, animated: true)
        return true
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        let isEmptyField = self.isEmptyField(with: textField)
        self.changeTextFieldVisibility(isVisible: !isEmptyField, animated: true)
        self.lisboaTextFieldDelegate?.textFieldDidEndEditing(textField)
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        let isEmptyField = self.isEmptyField(with: textField)
        self.changeTextFieldVisibility(isVisible: !isEmptyField, animated: true)
        self.lisboaTextFieldDelegate?.textFieldDidEndEditing(textField)
    }

    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        self.changeTextFieldVisibility(isVisible: true, animated: true)
        return true
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.textField.resignFirstResponder()
        self.keyboardReturnAction?()
        return true
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let characterSet = self.availableCharacterSet else { return true }
        let character = CharacterSet(charactersIn: string)
        return characterSet.isSuperset(of: character)
    }
}

extension FloatingTitleLisboaTextField: TextFieldNotifiableProtocol {
    func setTextFieldFocus() {
        self.textField.becomeFirstResponder()
    }
}
