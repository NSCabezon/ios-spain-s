//

import UIKit

class OperativeSeparatorTableViewCell: BaseViewCell {
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var leftConstraint: NSLayoutConstraint!
    @IBOutlet weak var rightConstraint: NSLayoutConstraint!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    
    var heightSepartor: Double = 1 {
        didSet {
            heightConstraint.constant = CGFloat(heightSepartor)
            layoutSubviews()
        }
    }
    
    func applyInsets(insets: Insets?) {
        if let insets = insets {
            bottomConstraint.constant = CGFloat(insets.bottom)
            leftConstraint.constant = CGFloat(insets.left)
            rightConstraint.constant = CGFloat(insets.right)
            topConstraint.constant = CGFloat(insets.top)
            layoutSubviews()
        }
    }
    
    func applyColor(color: OperativeSeparatorColor) {
        switch color {
        case .normal:
            separatorView.backgroundColor = .lisboaGray
        case .background:
            separatorView.backgroundColor = .sanGreyLight
        case .paleGrey:
            separatorView.backgroundColor = .uiBackground
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        selectionStyle = .none
    }
}
