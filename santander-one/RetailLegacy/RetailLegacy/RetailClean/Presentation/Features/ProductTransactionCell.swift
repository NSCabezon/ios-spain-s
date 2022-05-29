import UIKit

protocol ProductTransactionCell {
    var isFirstTransaction: Bool { get }
    
    var shortSeparator: UIView! { get }
    var longSeparator: UIView! { get }
    
    func showSeparator(_ complete: Bool)
}

extension ProductTransactionCell {
    func showSeparator(_ complete: Bool) {
        if complete {
            longSeparator.backgroundColor = .lisboaGray
            shortSeparator.backgroundColor = .lisboaGray
        } else {
            longSeparator.backgroundColor = UIColor.lisboaGray.withAlphaComponent(0.48)
            shortSeparator.backgroundColor = UIColor.lisboaGray.withAlphaComponent(0.48)
        }
        longSeparator.isHidden = isFirstTransaction
        shortSeparator.isHidden = (isFirstTransaction || !complete)
        
    }
}
