import UIKit

public protocol ViewCreatable {
    static func instantiateFromNib() -> Self?
}

extension ViewCreatable where Self: UIView {
    
    public static var nib: UINib {
        
        return UINib(nibName: "\(self)", bundle: .module)
    }
    
    public static func instantiateFromNib() -> Self? {
        
        func instanceFromNib<T: UIView>() -> T? {
            
            let nibView = nib.instantiate() as? T
            nibView?.translatesAutoresizingMaskIntoConstraints = false
            
            return nibView
        }
        
        return instanceFromNib()
    }
}
