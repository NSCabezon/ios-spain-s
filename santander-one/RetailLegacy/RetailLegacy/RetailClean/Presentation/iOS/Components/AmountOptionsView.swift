import UIKit
import CoreFoundationLib

class AmountOptionsView: UIView {
    
    private lazy var textField: FormattedTextField = {
        let textField = FormattedTextField()
        let paddingView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 20))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        textField.font = .latoRegular(size: 18)
        textField.borderStyle = .none
        textField.keyboardType = .decimalPad
        textField.layer.cornerRadius = 5
        textField.layer.masksToBounds = true
        textField.layer.borderColor = UIColor.lisboaGray.cgColor
        textField.layer.borderWidth = 1
        textField.textFormatMode = FormattedTextField.FormatMode.defaultCurrency(12, 2)
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private lazy var amountsStackView: OptionsStackView = {
        let stackView = OptionsStackView()
        stackView.alignment = .fill
        stackView.distribution = .fillProportionally
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    var options = [ValueOptionType]() {
        didSet {
            for option in options {
                option.action = { [weak self] in
                    self?.textField.formatWith(string: option.value)
                    self?.textfieldDidChanged()
                }
            }
            amountsStackView.addValues(options)
        }
    }
    
    var enteredTextDidChange: ((String?) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    private func setupView() {
        addSubview(textField)
        textField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        textField.topAnchor.constraint(equalTo: topAnchor).isActive = true
        addSubview(amountsStackView)
        amountsStackView.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 16.0).isActive = true
        amountsStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10).isActive = true
        amountsStackView.leftAnchor.constraint(equalTo: leftAnchor, constant: 0).isActive = true
        amountsStackView.rightAnchor.constraint(equalTo: rightAnchor, constant: 0).isActive = true
        textField.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        textField.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        textField.addTarget(self, action: #selector(textfieldDidChanged), for: .editingChanged)
    }
    
    func setPlaceholderText(_ text: LocalizedStylableText?) {
        let attrs = [NSAttributedString.Key.font: UIFont.latoItalic(size: 16.0), .foregroundColor: UIColor.sanGreyMedium]
        textField.setOnPlaceholder(localizedStylableText: text ?? .empty,
                                   attributes: attrs)
    }
    
    func setKeyboardTextFieldOrder(_ order: KeyboardTextFieldResponderOrder) {
        textField.reponderOrder = order
    }
    
    @objc func textfieldDidChanged() {
        if options.isEmpty {
            enteredTextDidChange?(textField.text)
            return
        }
        for option in options {
            option.setHighlightedIfMatches(value: textField.text)
            enteredTextDidChange?(textField.text)
        }
    }
    
    func setAccessibilityIdentifers(identifier: String) {
        textField.isAccessibilityElement = false
        setAccessibility { self.textField.isAccessibilityElement = true }
        textField.accessibilityIdentifier = identifier + "_textField"
        textField.rightImageIdentifier = identifier + "_textFieldImage"
    }
}

extension AmountOptionsView: SelectableCustomView {
    func onSelection(isSelected: Bool) {
        if !isSelected {
            textField.text = nil
            textfieldDidChanged()
        }
    }
}

extension AmountOptionsView: AccessibilityCapable { }
