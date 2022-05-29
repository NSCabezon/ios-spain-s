//
//  KeyboardManager.swift
//  UI
//
//  Created by José Carlos Estela Anguita on 17/07/2020.
//

import Foundation
import CoreFoundationLib
import UIKit

public protocol KeyboardManagerDelegate: AnyObject {
    var keyboardManager: KeyboardManager { get }
    var associatedView: UIView { get }
    var keyboardManagerViewController: UIViewController { get }
    var keyboardButton: KeyboardManager.ToolbarButton? { get }
    var associatedScrollView: UIScrollView? { get }
}

extension KeyboardManagerDelegate where Self: UIViewController {
    public var keyboardManagerViewController: UIViewController {
        return self
    }
    public var associatedView: UIView {
        return self.view
    }
    public var keyboardButton: KeyboardManager.ToolbarButton? {
        return nil
    }
    public var associatedScrollView: UIScrollView? {
        return nil
    }
}

public protocol EditText: UITextInput, UIView {
    var inputAccessoryView: UIView? { get set }
    var isEnabled: Bool { get set }
}
 
extension UITextField: EditText {}
extension UITextView: EditText {
    public var isEnabled: Bool {
        get {
            return self.isEditable
        }
        set {
            self.isEditable = newValue
        }
    }
}

public final class KeyboardManager {

    // MARK: - Attributes
    
    private weak var delegate: KeyboardManagerDelegate? {
        didSet {
            self.keyboardButtonConfiguration = self.delegate?.keyboardButton.map { KeyboardManager.ToolbarButtonConfiguration(button: $0, isEnabled: false) }
            self.update()
        }
    }
    private var keyboardButtonConfiguration: KeyboardManager.ToolbarButtonConfiguration?
    private var textfields: [EditText] {
        return self.sorted(editTexts: (self.editTextsOfType(UITextView.self) + self.editTextsOfType(UITextField.self)))
    }
    private var keyboardDismisser: KeyboardDismisser?
    private enum Constants {
        static let textfieldOriginYMargin = CGFloat(15) // Fixed margin for textfields with a title
    }
    
    // MARK: - Public methods
    
    public init() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardWillShow(_:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        self.keyboardDismisser?.stop()
    }
    
    public func setDelegate(_ delegate: KeyboardManagerDelegate) {
        self.delegate = delegate
        self.keyboardDismisser = self.delegate.map { KeyboardDismisser(viewController: $0.keyboardManagerViewController) }
        self.keyboardDismisser?.start()
    }
    
    public func update() {
        self.textfields.enumerated().forEach {
            let toolbar = self.toolbar(for: $0.offset, textfield: $0.element)
            $0.element.inputAccessoryView = toolbar
            $0.element.reloadInputViews()
        }
    }
    
    public func setKeyboardButtonEnabled(_ isEnabled: Bool) {
        self.keyboardButtonConfiguration?.isEnabled = isEnabled
        self.update()
    }
}

private extension KeyboardManager {
    
    func editTextsOfType<T: EditText>(_ type: T.Type) -> [T] {
        guard let view = self.delegate?.associatedView else { return [] }
        let editTexts = view.allSubViewsOf(type: T.self).filter {
            $0.isEnabled == true &&
            $0.isUserInteractionEnabled == true &&
            $0.anySuperViewIsHidden() == false
        }
        return editTexts
    }

    func sorted(editTexts: [EditText]) -> [EditText] {
        guard let view = self.delegate?.associatedView else { return [] }
        return editTexts.sorted {
            $0.convert($0.bounds, to: view).origin.y < $1.convert($1.bounds, to: view).origin.y
        }
    }

    @objc func keyboardWillShow(_ notification: Notification) {
        guard let scrollView = self.delegate?.associatedScrollView, let currentTextfield = self.textfields.first(where: { $0.isFirstResponder == true }) else { return }
        let currentTextFieldOriginY = currentTextfield.convert(currentTextfield.bounds, to: scrollView).origin.y - Constants.textfieldOriginYMargin
        guard scrollView.contentOffset.y > currentTextFieldOriginY else { return }
        UIView.animate(withDuration: 0.2) {
            scrollView.contentOffset = CGPoint(x: 0, y: currentTextFieldOriginY)
        }
    }
    
    func toolbar(for index: Int, textfield: EditText) -> Toolbar {
        let toolbar = Toolbar(textfield: textfield, toolbarDelegate: self)
        self.setupToolbar(toolbar, at: index, textfield: textfield)
        return toolbar
    }
    
    func setupToolbar(_ toolbar: Toolbar, at index: Int, textfield: EditText) {
        switch index {
        case 0 where self.textfields.count > 1:
            toolbar.setupWithConfiguration(KeyboardManager.ToolbarConfiguration(isNextEnabled: true, isPreviousEnabled: false, buttonConfiguration: self.keyboardButtonConfiguration))
        case 0 where self.textfields.count == 1:
             toolbar.setupWithConfiguration(KeyboardManager.ToolbarConfiguration(isNextEnabled: false, isPreviousEnabled: false, buttonConfiguration: self.keyboardButtonConfiguration))
        case self.textfields.count - 1:
             toolbar.setupWithConfiguration(KeyboardManager.ToolbarConfiguration(isNextEnabled: false, isPreviousEnabled: true, buttonConfiguration: self.keyboardButtonConfiguration))
        default:
            toolbar.setupWithConfiguration(KeyboardManager.ToolbarConfiguration(isNextEnabled: true, isPreviousEnabled: true, buttonConfiguration: self.keyboardButtonConfiguration))
        }
    }
}

extension KeyboardManager: ToolbarKeyboardDelegate {
    func previousKeyboardSelected(_ textfield: EditText) {
        guard let index = self.textfields.enumerated().first(where: { $0.element == textfield })?.offset, self.textfields.indices.contains(index - 1) == true else { return }
        self.textfields[index - 1].becomeFirstResponder()
    }
    
    func nextKeyboardSelected(_ textfield: EditText) {
        guard let index = self.textfields.enumerated().first(where: { $0.element == textfield })?.offset, self.textfields.indices.contains(index + 1) == true else { return }
        self.textfields[index + 1].becomeFirstResponder()
    }
    
    func buttonSelected(_ textfield: EditText) {
        textfield.resignFirstResponder()
    }
}
