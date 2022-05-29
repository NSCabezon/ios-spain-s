import UIKit

class SeparatorItemView: StackItemView {
    @IBOutlet weak var viewHeight: NSLayoutConstraint!
    @IBOutlet weak var separatorView: UIView!
    
    var separatorColor: UIColor = .lisboaGray {
        didSet {
            separatorView.backgroundColor = separatorColor
        }
    }
    
    func applyHeight(height: Double) {
        self.viewHeight.constant = CGFloat(height)
        layoutIfNeeded()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        separatorView.backgroundColor = separatorColor
        backgroundColor = .clear
    }
}
