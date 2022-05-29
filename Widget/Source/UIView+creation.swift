import UIKit

extension UIView {
    
    public static var nib: UINib {
        return UINib(nibName: "\(self)",
                     bundle: Bundle(for: self))
    }

    public static func initFromNib() -> Self? {
        func instanceFromNib<T: UIView>() -> T? {
            let nibView = self.nib.instantiate(withOwner: self,
                                               options: nil).first as? T
            nibView?.translatesAutoresizingMaskIntoConstraints = false
            return nibView
        }
        return instanceFromNib()
    }
}
