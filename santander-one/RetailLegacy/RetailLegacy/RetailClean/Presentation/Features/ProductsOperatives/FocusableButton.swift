import UIKit

/// This class was created solve the problem that a button coulnd't be tapped while it was displayed the keyboard in the Signature screen
/// It just overrides the `canBecomeFocused` property

class FocusableButton: UIButton {
    
    override var canBecomeFocused: Bool {
        return true
    }
}
