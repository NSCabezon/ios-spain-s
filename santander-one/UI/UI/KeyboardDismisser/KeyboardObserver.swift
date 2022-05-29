import UIKit

protocol KeyboardObserverDelegate: AnyObject {
    func keyboardEventDidHappen(event: KeyboardEvent)
}

enum KeyboardEvent {
    case willShow
    case didHide
}

class KeyboardObserver {
    weak var delegate: KeyboardObserverDelegate?
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(KeyboardObserver.keyboardDidHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc
    private func keyboardWillShow() {
        delegate?.keyboardEventDidHappen(event: .willShow)
    }
    
    @objc
    private func keyboardDidHide() {
        delegate?.keyboardEventDidHappen(event: .didHide)
    }
}
