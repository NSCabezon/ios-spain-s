import UIKit

open class TextFieldController: NSObject, UITextFieldDelegate {
    
    public init(textField: ResponsiveTextField) {
        super.init()
        textField.delegate = self
        textField.addTarget(self, action: #selector(textFieldDidChangeValue(textField:)), for: .editingChanged)
    }
    
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        guard let responsiveTextfield = textField as? ResponsiveTextField else {
            return
        }
        responsiveTextfield.onSelection?(responsiveTextfield)
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let responsiveTextField = textField as? ResponsiveTextField, let text = textField.text else {
            return false
        }
        
        guard let newRange = Range(range, in: text) else { return false }
        
        let result = (textField.text ?? "").replacingCharacters(in: newRange, with: string)
        var exitRule = responsiveTextField.maxLength == noLimit || result.count <= responsiveTextField.maxLength
        
        if exitRule, let canChange = responsiveTextField.canChange {
            exitRule = canChange(result)
        }
        
        return exitRule
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        guard let responsiveTextField = textField as? ResponsiveTextField else {
            return
        }
        responsiveTextField.onLeaving?(responsiveTextField)
    }
    
    @objc
    public func textFieldDidChangeValue(textField: UITextField) {
        guard let responsiveTextField = textField as? ResponsiveTextField else {
            return
        }
        responsiveTextField.onChange?()
    }
}

private let noLimit = 0
public typealias CanChange = ((_ newText: String) -> Bool)
public typealias OnChange = (() -> Void)
public typealias OnSelection = ((_ textField: UITextField) -> Void)
public typealias OnLeaving = ((_ textField: UITextField) -> Void)

open class ResponsiveTextField: KeyboardTextField {
    override open var delegate: UITextFieldDelegate? {
        didSet {
            guard delegate == nil || delegate is TextFieldController else {
                fatalError("Error: this text field delegates on TextFieldController class")
            }
        }
    }
    public var maxLength: Int = noLimit {
        didSet {
            checkController()
        }
    }
    public var onSelection: OnSelection? {
        didSet {
            checkController()
        }
    }
    public var canChange: CanChange? {
        didSet {
            checkController()
        }
    }
    public var onChange: OnChange? {
        didSet {
            checkController()
        }
    }
    
    public var onLeaving: OnLeaving? {
        didSet {
            checkController()
        }
    }
    
    var controller: TextFieldController!
    
    public var padding = UIEdgeInsets(top: 0.0, left: 15.0, bottom: 0.0, right: 15.0)
    
    private func checkController() {
        if controller == nil {
            controller = TextFieldController(textField: self)
        }
    }
    
    private var leftSideWidth: CGFloat {
        if leftViewMode == .always || leftViewMode == .unlessEditing {
            return leftView?.frame.width ?? 0.0
        }
        return CGFloat()
    }
    
    private var rightSideWidth: CGFloat {
        if rightViewMode == .always || rightViewMode == .unlessEditing {
            return rightView?.frame.width ?? 0.0
        }
        return CGFloat()
    }
    
    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        return rectForText(bounds: bounds)
    }
    
    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return rectForText(bounds: bounds)
    }
    
    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        return rectForText(bounds: bounds)
    }
    
    private func rectForText(bounds: CGRect) -> CGRect {
        let rect = bounds.inset(by: padding)
//        let rect = UIEdgeInsetsInsetRect(bounds, padding)
        return adjustRectWithSidesViews(bounds: rect)
    }
    
    private func adjustRectWithSidesViews(bounds: CGRect) -> CGRect {
        var paddedRect = bounds
        paddedRect.origin.x += leftSideWidth
        paddedRect.size.width -= leftSideWidth
        paddedRect.size.width -= rightSideWidth
        
        return paddedRect
    }
    
    override open func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return false
    }
}
