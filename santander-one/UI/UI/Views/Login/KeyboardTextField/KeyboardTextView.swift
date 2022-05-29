import UIKit
import IQKeyboardManagerSwift
import CoreFoundationLib

open class KeyboardTextView: UITextView {
    
    private lazy var keyboardDelegate = KeyboardTextViewDelegate(field: self)
    public var reponderOrder: KeyboardTextFieldResponderOrder = .position {
        didSet {
            keyboardDelegate.siblingOrder = reponderOrder
        }
    }
    
    override public init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        delegate = nil
        tintColor = UIColor.Legacy.sanRed
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        delegate = nil
        tintColor = UIColor.Legacy.sanRed
    }
    
    override open var delegate: UITextViewDelegate? {
        get {
            return keyboardDelegate
        }
        set {
            keyboardDelegate.delegate = newValue
            super.delegate = keyboardDelegate
        }
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        if let label = self.subviews.first(where: { $0 is UILabel }) as? UILabel {
            label.minimumScaleFactor = 0.3
            label.adjustsFontSizeToFitWidth = true
        }
    }
    
    override public func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(copy(_:)) || action == #selector(cut(_:)) {
            return false
        } else {
            return super.canPerformAction(action, withSender: sender)
        }
    }
    
}

open class KeyboardTextViewDelegate: NSObject {
    
    public unowned let field: UITextView
    public var siblingOrder: KeyboardTextFieldResponderOrder = .position
    public var nextButtonTitle: String = ""
    public var doneButtonTitle: String = ""
    
    public init(field: UITextView) {
        self.field = field
        super.init()
        NotificationCenter.default.post(name: KeyboardNotifications.globalKeyboardCreateNotification, object: self)
    }
    
    fileprivate weak var delegate: UITextViewDelegate?
    
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
            let subviews = superView.subviews
            for subview in subviews where subview != view {
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
            for index in (index + 1)..<subviews.count {
                let subview = subviews[index]
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
}

extension KeyboardTextViewDelegate: UITextViewDelegate {
    
    @objc public func actionDone() {
        if let view = getNextResponderView() {
            view.becomeFirstResponder()
        } else {
            field.resignFirstResponder()
        }
    }
    
    public func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        return delegate?.textViewShouldBeginEditing?(textView) ?? true
    }
    
    public func textViewDidBeginEditing(_ textView: UITextView) {
        IQKeyboardManager.shared.enableAutoToolbar = false
        let toolbar = textView.keyboardToolbar
        toolbar.barStyle = UIBarStyle.default
        toolbar.barTintColor = UIColor.Legacy.sanRed
        toolbar.tintColor = UIColor.Legacy.uiWhite
        toolbar.doneBarButton.setTitleTextAttributes([.font: UIFont.santander(family: .lato, type: .bold, size: 16)], for: .normal)
        let types: Set<UIKeyboardType>
        if #available(iOS 10.0, *) {
            types = [.numberPad, .decimalPad, .phonePad, .asciiCapableNumberPad]
        } else {
            types = [.numberPad, .decimalPad, .phonePad]
        }
        if textView.inputView != nil || types.contains(textView.keyboardType) {
            let text: String
            if getNextResponderView() != nil {
                text = nextButtonTitle
            } else {
                text = doneButtonTitle
            }
            field.addRightButtonOnKeyboardWithText(text, target: self, action: #selector(actionDone), titleText: "")
        } else {
            let returnKey: UIReturnKeyType
            if getNextResponderView() != nil {
                returnKey = .next
            } else {
                returnKey = .done
            }
            textView.returnKeyType = returnKey
        }
        delegate?.textViewDidBeginEditing?(textView)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak textView] in
            // Hay un bug en la libreía IQKeyboardManager que pasa solo en los textviews con cuando funciona textViewDidBeginEditing ()
            guard let textView = textView else { return }
            textView.reloadInputViews()
        }
    }
    
    public func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        return delegate?.textViewShouldEndEditing?(textView) ?? true
    }
    
    public func textViewDidEndEditing(_ textView: UITextView) {
        IQKeyboardManager.shared.enableAutoToolbar = true
        IQKeyboardManager.shared.toolbarDoneBarButtonItemText = doneButtonTitle
        delegate?.textViewDidEndEditing?(textView)
    }

    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return delegate?.textView?(textView, shouldChangeTextIn: range, replacementText: text) ?? true
    }
    
    public func textViewDidChange(_ textView: UITextView) {
        delegate?.textViewDidChange?(textView)
    }
}

extension KeyboardTextViewDelegate: KeyboardTextFieldResponderButtons {}
