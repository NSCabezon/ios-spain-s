import UIKit
import CoreFoundationLib

class DepositMoneyIntoCardHeaderConfirmationTableViewCell: BaseViewCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var cardImageView: UIImageView!
    @IBOutlet weak var aliasNameLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.backgroundColor = .uiBackground
        aliasNameLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: UIFont.latoBold(size: 14), textAlignment: .left))
        amountLabel.applyStyle(LabelStylist(textColor: .sanRed, font: UIFont.latoBold(size: 16), textAlignment: .left))
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        applyRoundedStyle()
    }
    
    func setAccessibilityIdentifiers(identifiers: PayOffConfirmationCardIdentifiers) {
        amountLabel.accessibilityIdentifier = identifiers.amount
        aliasNameLabel.accessibilityIdentifier = identifiers.alias
        cardImageView.isAccessibilityElement = true
        setAccessibility { self.cardImageView.isAccessibilityElement = false }
        cardImageView.accessibilityIdentifier = identifiers.image
    }
    
    private func applyRoundedStyle() {
        StylizerPGViewCells.applyMiddleViewCellStyle(view: containerView)
    }
}

extension DepositMoneyIntoCardHeaderConfirmationTableViewCell: AccessibilityCapable { }
