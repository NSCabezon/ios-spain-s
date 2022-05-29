//

import UIKit

protocol GenericSignatureTextFieldDelegate: AnyObject {
    func textFieldDidDelete(with textField: UITextField)
}

class GenericSignatureTextField: UITextField {
    weak var textFieldDelegate: GenericSignatureTextFieldDelegate?
    var textSignature: String? {
        didSet {
            self.accessibilityValue = textSignature
        }
    }
    let padding = UIEdgeInsets(top: 15, left: 0, bottom: 0, right: 0)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        tintColor = .sanRed
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        tintColor = .sanRed
    }
    
    override func deleteBackward() {
        super.deleteBackward()
        textFieldDelegate?.textFieldDidDelete(with: self)
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return false
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
}
