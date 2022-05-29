import UIKit

public enum KeyboardNumericBarButton: Int {
    case zero = 0
    case one
    case two
    case three
    case four
    case five
    case six
    case seven
    case eight
    case nine
    
    func createButton(target: Any, action: Selector) -> UIView {
        let button = KeyboardNumericButton()
        button.setTitle("\(rawValue)", for: .normal)
        button.tag = rawValue
        button.addTarget(target, action: action, for: .touchUpInside)
        return button
    }
}

open class KeyboardNumericBar: UIInputView {
    public weak var textField: KeyboardTextField?
    private var itemWidth: CGFloat {
        let width = UIScreen.main.bounds.width
        let maxAvailableSpace = width - (11 * 3) // 11 huecos de minimo 3 pixeles
        let maxWidth = maxAvailableSpace / 10 // 10 botones
        return min(31, maxWidth)
    }
    private var itemHeight: CGFloat {
        return itemWidth * 42 / 31
    }
    private let verticalSeparator: CGFloat = 9
    public var totalHeight: CGFloat {
        return verticalSeparator + itemHeight + verticalSeparator
    }
    
    public static func create(textField: UITextField) {
        let toolbar = KeyboardNumericBar(frame: .zero, inputViewStyle: .keyboard)
        toolbar.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: toolbar.totalHeight)
        toolbar.textField = textField as? KeyboardTextField
        textField.inputAccessoryView = toolbar
        toolbar.setup()
    }
    
    public func setup() {
        let stackView = UIStackView()
        stackView.frame = bounds
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.axis = .horizontal
        addSubview(stackView)
        addSpacer(stackView: stackView)
        for index in 1...9 {
            addItem(index: index, stackView: stackView)
        }
        addItem(index: 0, stackView: stackView)
        addSpacer(stackView: stackView)
    }
    
    private func addSpacer(stackView: UIStackView) {
        let spacer = UIView()
        spacer.frame = .zero
        spacer.backgroundColor = UIColor.Legacy.sanRed
        stackView.addArrangedSubview(spacer)
    }
    
    private func addItem(index: Int, stackView: UIStackView) {
        if let item = KeyboardNumericBarButton(rawValue: index) {
            let button = item.createButton(target: self, action: #selector(buttonTapped))
            button.frame = CGRect(x: 0, y: 0, width: itemWidth, height: itemHeight)
            stackView.addArrangedSubview(button)
        }
    }
    
    @objc public func buttonTapped(sender: UIButton) {
        guard let type = KeyboardNumericBarButton(rawValue: sender.tag), let textField = textField, let range = selectedRange(textField: textField) else {
            return
        }
        guard textField.keyboardDelegate.textField(textField, shouldChangeCharactersIn: range, replacementString: "\(type.rawValue)") == true else {
            return
        }
        textField.insertText("\(type.rawValue)")
    }
    
    private func selectedRange(textField: UITextField) -> NSRange? {
        guard let range = textField.selectedTextRange else { return nil }
        let location = textField.offset(from: textField.beginningOfDocument, to: range.start)
        let length = textField.offset(from: range.start, to: range.end)
        return NSRange(location: location, length: length)
    }
}
