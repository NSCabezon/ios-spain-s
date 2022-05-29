import UIKit

extension UITableViewCell {
	public static func nibString() -> String {
		return String(describing: self)
	}
	
	public static func nib() -> UINib {
		return UINib.init(nibName: nibString(), bundle: nil)
	}
}
