import UIKit

class ChangeLogFirstViewCellItem: GroupableTableViewCell {
    
    var title: String? {
        didSet {
            if let title = title {
                titleLabel.text = title
            } else {
                titleLabel.text = nil
            }
        }
    }
    
    override var isFirst: Bool {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override var isLast: Bool {
        didSet {
            separator.isHidden = true
        }
    }
    
    override var roundedView: UIView {
        return containerView
    }
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .latoSemibold(size: 16.0)))
        backgroundColor = .clear
        selectionStyle = .none
    }
}
