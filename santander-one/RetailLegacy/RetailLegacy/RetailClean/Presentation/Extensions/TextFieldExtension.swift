//

import UIKit

extension UITextField {
    //Ways to validate by comparison
    enum textFieldValidationOptions: Int {
        case equalTo
        case greaterThan
        case greaterThanOrEqualTo
        case lessThan
        case lessThanOrEqualTo
    }
    
    ///Validation length of character counts in UITextField
    func validateLength(ofCount count: Int, option: UITextField.textFieldValidationOptions) -> Bool {
        guard let unwrappText = self.text else { return false }
        switch option {
        case .equalTo:
            return unwrappText.count == count
        case .greaterThan:
            return unwrappText.count > count
        case .greaterThanOrEqualTo:
            return unwrappText.count >= count
        case .lessThan:
            return unwrappText.count < count
        case .lessThanOrEqualTo:
            return unwrappText.count <= count
        }
    }
}

extension UITextField: ContentResetable {
    func resetContent() {
        text = nil
    }
}
