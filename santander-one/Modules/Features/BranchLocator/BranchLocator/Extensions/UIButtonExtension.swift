import UIKit

extension UIButton {
	func setBackgroundColor(_ color: UIColor, forState state: UIControl.State) {
		setBackgroundImage(UIImage(with: color), for: .normal)
	}

}

