//

import UIKit
import IQKeyboardManagerSwift
import CoreFoundationLib

public enum KeyboardTextFieldResponderOrder {
    case position
    case tag
    case subview
    case none
}

open class KeyboardTextField: UITextField {

    public lazy var keyboardDelegate = KeyboardTextFieldDelegate(field: self)
    public var reponderOrder: KeyboardTextFieldResponderOrder = .position {
        didSet {
            keyboardDelegate.siblingOrder = reponderOrder
        }
    }
    public var isEndabledNumbericBar: Bool = true {
        didSet {
            keyboardDelegate.isEndabledNumbericBar = isEndabledNumbericBar
        }
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    private func setupView() {
        delegate = nil
        tintColor = UIColor.Legacy.sanRed
        backgroundColor = .white
    }
    
    override open var delegate: UITextFieldDelegate? {
        get {
            return keyboardDelegate.delegate
        }
        set {
            keyboardDelegate.delegate = newValue
            super.delegate = keyboardDelegate
        }
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        if let label = self.subviews.first(where: { $0 is UILabel }) as? UILabel {
            label.minimumScaleFactor = 0.3
            label.adjustsFontSizeToFitWidth = true
        }
    }
    
    override open func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(copy(_:)) || action == #selector(cut(_:)) {
            return false
        } else {
            return super.canPerformAction(action, withSender: sender)
        }
    }
}

open class KeyboardTextFieldDelegate: NSObject {
    public var isEndabledNumbericBar: Bool = true
    public unowned let field: UITextField
    public var siblingOrder: KeyboardTextFieldResponderOrder = .position
    public var nextButtonTitle: String = ""
    public var doneButtonTitle: String = ""
    private var placeholder: String?
    private var isKeyboardToolbar = false
    
    public init(field: UITextField) {
        self.field = field
        super.init()
        NotificationCenter.default.post(name: KeyboardNotifications.globalKeyboardCreateNotification, object: self)
    }
    
    fileprivate weak var delegate: UITextFieldDelegate?
    
    fileprivate func getNextResponderView() -> UIView? {
        switch siblingOrder {
        case .subview:
            return getNextResponderBySubviews(view: field)
        case .tag:
            return getNextResponderByTag(view: field, tag: field.tag)
        case .position:
            let origin = getOrigin(view: field)
            return getNextResponderByPosition(view: field, origin: origin)
        case .none:
            return nil
        }
    }
    
    @objc private func keyboardDidAppear(notification: Notification) {
        NotificationCenter.default.removeObserver(self, name: KeyboardNotifications.globalKeyboardCreateNotification, object: self)
        if isKeyboardToolbar {
            updateKeyboardToolbar()
        } else {
            updateKeyboard()
        }
    }
    
    private func getOrigin(view: UIView) -> CGPoint {
        var point: CGPoint = view.frame.origin
        var originView = view.superview
        while let originViewUnwrapped = originView, let superView = originViewUnwrapped.superview, originView != UIApplication.shared.keyWindow?.rootViewController?.view {
            point = originViewUnwrapped.convert(point, to: superView)
            originView = superView
        }
        return point
    }
    
    private func checkOriginView(origin: CGPoint, view: UIView) -> Bool {
        let frame = getOrigin(view: view)
        if frame.y > origin.y {
            return true
        } else if frame.y == origin.y && frame.x > origin.x {
            return true
        } else {
            return false
        }
    }
    
    private func getAllSiblings(view: UIView) -> [UIView] {
        var views: [UIView] = []
        if let superView: UIView = view.superview {
            for subview in superView.subviews where subview != view && !subview.isHidden {
                if let textInput = getViewResponder(view: subview) {
                    views.append(textInput)
                }
            }
            views.append(contentsOf: getAllSiblings(view: superView))
        }
        return views
    }
    
    private func compareOrigin(firstView: UIView, secondView: UIView) -> Bool {
        let firstOrigin = getOrigin(view: firstView)
        let secondOrigin = getOrigin(view: secondView)
        if firstOrigin.y > secondOrigin.y {
            return false
        } else if firstOrigin.y < secondOrigin.y {
            return true
        } else {
            return firstOrigin.x < secondOrigin.x
        }
    }
    
    private func getNextResponderByPosition(view: UIView, origin: CGPoint) -> UIView? {
        let allSiblings = getAllSiblings(view: view)
        let allSiblingsByOrigin = allSiblings.filter { siblingView in
            return checkOriginView(origin: origin, view: siblingView)
        }
        let allSiblingsByOriginSorted = allSiblingsByOrigin.sorted { (firstView, secondView) -> Bool in
            return compareOrigin(firstView: firstView, secondView: secondView)
        }
        return allSiblingsByOriginSorted.first
    }
    
    private func getNextResponderByTag(view: UIView, tag: Int) -> UIView? {
        let allSiblings = getAllSiblings(view: view)
        let allSiblingsByTag = allSiblings.filter { siblingView in
            return siblingView.tag > tag
        }
        let allSiblingsByTagOrdered = allSiblingsByTag.sorted(by: { (firstView, secondView) -> Bool in
            return firstView.tag < secondView.tag
        })
        return allSiblingsByTagOrdered.first
    }
    
    private func getNextResponderBySubviews(view: UIView) -> UIView? {
        guard let superView: UIView = view.superview else {
            return nil
        }
        let subviews = superView.subviews
        if let index = subviews.firstIndex(of: view), index + 1 < subviews.count {
            for idx in (index + 1)..<subviews.count {
                let subview = subviews[idx]
                if let textInput = getViewResponder(view: subview) {
                    return textInput
                }
            }
        }
        return getNextResponderBySubviews(view: superView)
    }
    
    private func getViewResponder(view: UIView) -> UIView? {
        if view is UITextInput && !view.isHidden {
            return view
        }
        for subview in view.subviews {
            if let textInput = getViewResponder(view: subview) {
                return textInput
            }
        }
        return nil
    }
    
    private func updateKeyboard() {
        isKeyboardToolbar = false
        if getNextResponderView() != nil {
            field.returnKeyType = .next
        } else {
            field.returnKeyType = .done
        }
    }
    
    private func updateKeyboardToolbar() {
        if getNextResponderView() != nil {
            field.addRightButtonOnKeyboardWithText(nextButtonTitle, target: self, action: #selector(actionDone), titleText: "")
        } else {
            field.addRightButtonOnKeyboardWithText(doneButtonTitle, target: self, action: #selector(actionDone), titleText: "")
        }
    }
    
    private func updateKeyboardToolbar(toolbar: IQToolbar) {
        isKeyboardToolbar = true
        toolbar.barStyle = UIBarStyle.default
        toolbar.barTintColor = UIColor.Legacy.sanRed
        toolbar.tintColor = UIColor.Legacy.uiWhite
        toolbar.doneBarButton.setTitleTextAttributes([.font: UIFont.santander(family: .lato, type: .bold, size: 16)], for: .normal)
        toolbar.doneBarButton.accessibilityIdentifier = AccessibilityOthers.doneBarButton.rawValue
        updateKeyboardToolbar()
    }
}

extension KeyboardTextFieldDelegate: UITextFieldDelegate {
    @objc public func actionDone() {
        if let view = getNextResponderView() {
            view.becomeFirstResponder()
        } else {
            field.resignFirstResponder()
        }
    }
    
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return delegate?.textFieldShouldBeginEditing?(textField) ?? true
    }
    
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        IQKeyboardManager.shared.enableAutoToolbar = false
        if textField.inputView != nil {
            updateKeyboardToolbar(toolbar: textField.keyboardToolbar)
        } else {
            switch textField.keyboardType {
            case .numberPad, .decimalPad, .phonePad, .asciiCapableNumberPad:
                updateKeyboardToolbar(toolbar: textField.keyboardToolbar)
            default:
                if isEndabledNumbericBar {
                    KeyboardNumericBar.create(textField: textField)
                }
                updateKeyboard()
            }
        }
        delegate?.textFieldDidBeginEditing?(textField)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidAppear(notification:)), name: UIResponder.keyboardDidShowNotification, object: nil)
    }
    
    public func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return delegate?.textFieldShouldEndEditing?(textField) ?? true
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        IQKeyboardManager.shared.enableAutoToolbar = true
        IQKeyboardManager.shared.toolbarDoneBarButtonItemText = doneButtonTitle
        delegate?.textFieldDidEndEditing?(textField)
    }
    
    @available(iOS 10.0, *)
    public func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        IQKeyboardManager.shared.enableAutoToolbar = true
        IQKeyboardManager.shared.toolbarDoneBarButtonItemText = doneButtonTitle
        delegate?.textFieldDidEndEditing?(textField, reason: reason)
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return delegate?.textField?(textField, shouldChangeCharactersIn: range, replacementString: string) ?? true
    }
    
    public func textFieldShouldClear(_ textField: UITextField) -> Bool {
        return delegate?.textFieldShouldClear?(textField) ?? true
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let view = getNextResponderView() {
            view.becomeFirstResponder()
        } else {
            field.resignFirstResponder()
        }
        return delegate?.textFieldShouldReturn?(textField) ?? false
    }
}

extension KeyboardTextFieldDelegate: KeyboardTextFieldResponderButtons {}
