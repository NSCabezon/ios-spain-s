import UIKit

class StackItemView: UIView {
    @IBOutlet weak var left: NSLayoutConstraint!
    @IBOutlet weak var right: NSLayoutConstraint!
    @IBOutlet weak var top: NSLayoutConstraint!
    @IBOutlet weak var bottom: NSLayoutConstraint!

    func applyInsets(insets: Insets) {
        left?.constant = CGFloat(insets.left)
        right?.constant = CGFloat(insets.right)
        top?.constant = CGFloat(insets.top)
        bottom?.constant = CGFloat(insets.bottom)
        layoutSubviews()
    }
}
