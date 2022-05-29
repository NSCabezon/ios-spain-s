//
//  SimpleLisboaTextField.swift
//  UI
//
//  Created by José Carlos Estela Anguita on 27/05/2020.
//

import CoreFoundationLib

final class SimpleLisboaTextField: XibView {
    
    // MARK: - Outlets
    @IBOutlet weak var textField: ConfigurableActionsTextField!
    @IBOutlet weak var mainStackView: UIStackView!
    @IBOutlet weak var bottomBorderView: UIView!
    @IBOutlet private weak var containerView: UIView!

    // MARK: - Attributes
    
    var text: String? {
        didSet {
            self.textField.text = text
            self.setTextSize()
        }
    }
    
    var placeholder: String? {
        didSet {
            self.textField.placeholder = self.placeholder
        }
    }
    
    var textFieldPlaceholder: String? {
        didSet {
            self.textField.placeholder = textFieldPlaceholder
        }
    }
    
    var style: LisboaTextFieldStyle = .default
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
    var fieldValue: String?
    private var keyboardReturnAction: (() -> Void)?
    private var availableCharacterSet: CharacterSet?
    private var textfieldCustomizationBlock: ((LisboaTextField.CustomizableComponents) -> Void)?
    
    // MARK: - Public
    
    func setReturnAction(_ action: (() -> Void)?) {
        self.keyboardReturnAction = action
    }
    
    func setCustomizationBlock(_ block: ((LisboaTextField.CustomizableComponents) -> Void)?) {
        self.textfieldCustomizationBlock = block
    }
}

private extension SimpleLisboaTextField {
    
    func isEmptyField(with textField: UITextField) -> Bool {
        let text = textField.text ?? ""
        let placeholder = textField.placeholder ?? ""
        return text.isEmpty && placeholder.isEmpty
    }
}

extension SimpleLisboaTextField: CustomizableTextFieldProtocol {
    
    func setRightViewOffset(_ offset: (x: CGFloat, y: CGFloat)) {
        self.textField.rightViewOffset = offset
    }
}

extension SimpleLisboaTextField: TextFieldDelegateConfigurable {}

extension SimpleLisboaTextField: LisboaTextFieldViewProtocol {
    func setTextSize() {
        switch adjustTextSize {
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
    
    func setup() {
        self.updateStyle()
        self.textfieldCustomizationBlock?(LisboaTextField.CustomizableComponents(textField: self.textField))
        self.textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }

    func updateStyle() {
        self.backgroundColor = self.style.backgroundColor
        self.containerView.backgroundColor = self.style.containerViewBackgroundColor
        self.containerView.layer.borderColor = self.style.containerViewBorderColor
        self.containerView.layer.borderWidth = self.style.containerViewBorderWidth
        self.textField.backgroundColor = self.style.fieldBackgroundColor
        self.textField.tintColor = self.style.fieldTintColor
        self.textField.textColor = self.style.fieldTextColor
        self.textField.font = self.style.fieldFont
        self.bottomBorderView.backgroundColor = self.style.verticalSeparatorBackgroundColor
    }
    
    @objc public func textFieldDidChange(_ textField: UITextField) {
        self.fieldValue = textField.text
        self.updatableDelegate?.updatableTextFieldDidUpdate()
    }
}

extension SimpleLisboaTextField: UITextFieldDelegate {
    
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
extension SimpleLisboaTextField: TextFieldNotifiableProtocol {
    func setTextFieldFocus() {
        self.textField.becomeFirstResponder()
    }
}

extension SimpleLisboaTextField: LisboaTextFieldResignableProtocol {
    func hideKeyboard() {
        self.textField.resignFirstResponder()
    }
}
