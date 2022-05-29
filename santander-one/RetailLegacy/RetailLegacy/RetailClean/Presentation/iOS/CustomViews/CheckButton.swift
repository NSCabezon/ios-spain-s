import UIKit

class CheckButton: ResponsiveButton {
    var onImage: UIImage? {
        didSet {
            setImage(onImage, for: .selected)
        }
    }
    var offImage: UIImage? {
        didSet {
            setImage(offImage, for: .normal)
        }
    }
    var onChange: (() -> Void)?
    
    override internal func didTouch(sender: ResponsiveButton) {
        isSelected = !isSelected
        onChange?()
    }
}
