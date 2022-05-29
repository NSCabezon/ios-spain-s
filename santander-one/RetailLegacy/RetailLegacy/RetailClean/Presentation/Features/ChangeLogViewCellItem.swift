import UIKit

class ChangeLogViewCellItem: GroupableTableViewCell {
    
    var value: String? {
        didSet {
            if let value = value {
                descriptionLabel.attributedText = value.htmlToAttributedString
            } else {
                descriptionLabel.text = nil
            }
        }
    }
    
    override var isLast: Bool {
        didSet {
            separator.isHidden = isLast
            containerBottomConstraint.constant = isLast ? 14 : 0
        }
    }
    
    override var roundedView: UIView {
        return containerView
    }
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet weak var containerBottomConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        descriptionLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .latoLight(size: 16)))
    }
}
