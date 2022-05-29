//

import UIKit
import CoreFoundationLib

class GenericOperativeCardHeaderView: BaseHeader, ViewCreatable {
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var cardImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var rightInfoLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupViews()
    }
    
    private func setupViews() {
        cardImageView.isAccessibilityElement = true
        cardImageView.accessibilityIdentifier = AccessibilityMobileRecharge.cardImage.rawValue
        cardImageView.image?.accessibilityIdentifier = AccessibilityMobileRecharge.cardImage.rawValue + "Image"
        titleLabel.accessibilityIdentifier = AccessibilityMobileRecharge.cardName.rawValue
        subtitleLabel.accessibilityIdentifier = AccessibilityMobileRecharge.cardNumber.rawValue
        rightInfoLabel.accessibilityIdentifier = AccessibilityMobileRecharge.cardRightLabel.rawValue
        amountLabel.accessibilityIdentifier = AccessibilityMobileRecharge.cardAmount.rawValue
        titleLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .latoRegular(size: 16)))
        subtitleLabel.applyStyle(LabelStylist(textColor: .sanGreyMedium, font: .latoRegular(size: 14)))
        rightInfoLabel.applyStyle(LabelStylist(textColor: .sanGreyMedium, font: .latoRegular(size: 14)))
        amountLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .latoBold(size: 16)))
    }
}
