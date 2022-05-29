import UIKit

final class EasyPaySeparatorTableViewCell: UITableViewCell {
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
    
    func applyColor(color: EasyPaySeparatorColor) {
        switch color {
        case .normal:
            separatorView.backgroundColor = .lisboaGray
        case .background:
            separatorView.backgroundColor = .prominentSanGray
        case .paleGrey:
            separatorView.backgroundColor = .bg
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        selectionStyle = .none
    }
}

extension EasyPaySeparatorTableViewCell: EasyPayTableViewCellProtocol {
    func setCellInfo(_ info: Any) {
        guard let info = info as? EasyPaySeparatorModelView else { return }
        heightSepartor = info.heightSepartor
        applyColor(color: info.color)
    }
}
