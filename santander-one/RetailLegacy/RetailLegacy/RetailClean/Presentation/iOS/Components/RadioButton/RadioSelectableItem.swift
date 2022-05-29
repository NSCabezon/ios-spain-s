import UIKit

struct RadioSelectableItemConstants {
    static var defaultNumericField: FormattedTextField {
        let field = FormattedTextField()
        field.keyboardType = .decimalPad
        
        return field
    }
}

class RadioSelectableItem<Type> {
    
    let type: Type
    var info: RadioTableInfo!
    var onTextChangeDelegate: OnRadioItemTextChangeDelegate?
    
    var field: UITextField? {
        if let created = _field {
            return created
        }
        return nil
    }
    
    var text: String? {
        return field?.text
    }

    var insets: UIEdgeInsets {
        return .zero
    }
    var height: CGFloat {
        return 0.0
    }
    var auxiliaryImage: UIImage? {
        return nil
    }
    
    private let title: LocalizedStylableText
    private let tag: Int
    private let isInitialIndex: Bool
    
    var _field: UITextField?
    
    init(title: LocalizedStylableText, type: Type, tag: Int, isInitialIndex: Bool, onTextChangeDelegate: OnRadioItemTextChangeDelegate? = nil) {
        self.title = title
        self.type = type
        self.tag = tag
        self.isInitialIndex = isInitialIndex
        self.info = nil
        self.onTextChangeDelegate = onTextChangeDelegate

        configure()

        _field?.addTarget(self, action: #selector(textDidChange(textField:)), for: UIControl.Event.editingChanged)
        _field?.addTarget(self, action: #selector(textDidChange(textField:)), for: UIControl.Event.editingDidEnd)
    }
    
    private func configure() {
        _field = field
        info = RadioTableInfo(title: title, view: _field, insets: insets, height: height, auxiliaryImage: auxiliaryImage, auxiliaryTag: tag, isInitialIndex: isInitialIndex)
        if let newField = _field {
            configureField(textField: newField)
        }
    }
    
    private func configureItem(title: LocalizedStylableText, insets: UIEdgeInsets, height: CGFloat, tag: Int, auxiliaryImage: UIImage?, isInitialIndex: Bool) {
        
    }
    
    private func configureField(textField: UITextField) {
        let paddingView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 20))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        textField.font = .latoRegular(size: 16)
        textField.textColor = .sanGreyDark
        textField.borderStyle = .none
        textField.layer.cornerRadius = 5
        textField.layer.masksToBounds = true
        textField.layer.borderColor = UIColor.lisboaGray.cgColor
        textField.layer.borderWidth = 1
    }
    
    @objc func textDidChange(textField: UITextField) {
        if let delegate = self.onTextChangeDelegate {
            delegate.textDidChange(tag: self.tag, text: textField.text)
        }
    }
}
