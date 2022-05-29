import UIKit
import CoreFoundationLib

class ConfirmationItemsListHeader: BaseViewCell {
    
    var titleText: String? {
        get {
            return title.text
        }
        set {
            title.text = newValue
            title.scaleDecimals()
            title.accessibilityIdentifier = AccessibilityInstantMoney.confirmationZoneLabelAmount.rawValue
        }
    }
    
    var descriptionText: String? {
        get {
            return descriptionLabel.text
        }
        set {
            descriptionLabel.isHidden = false
            descriptionLabel.text = newValue
        }
    }
    
    var type: ConfirmationTableViewHeaderType = .first {
        didSet {
            bottomSpaceConstraint.constant = (type == .last || type == .alone) ? 10 : 0
            stackViewBottomSpaceConstraint.constant = (type == .last || type == .alone) ? 8 : 0
            separator.isHidden = (type != .firstWithSeparator)
        }
    }
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var separator: UIView!
    @IBOutlet weak var bottomSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var stackViewBottomSpaceConstraint: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()
        title.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .latoBold(size: 30)))
        descriptionLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .latoBold(size: 14)))
        title.numberOfLines = 1
        backgroundColor = .clear
        selectionStyle = .none
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        applyRoundedStyle()
    }
    
    private func applyRoundedStyle() {
        switch type {
        case .first:
            StylizerPGViewCells.applyHeaderOpenViewCellStyle(view: containerView)
        case .firstWithSeparator:
            StylizerPGViewCells.applyHeaderOpenViewCellStyle(view: containerView)
        case .alone:
            StylizerPGViewCells.applyHeaderCloseViewCellStyle(view: containerView)
        case .last:
            StylizerPGViewCells.applyBottomViewCellStyle(view: containerView)
        }
    }
    
    func setAccessiblityIdentifiers(identifier: String) {
        title.accessibilityIdentifier = identifier + "_title"
        descriptionLabel.accessibilityIdentifier = identifier + "_desc"
    }
}
