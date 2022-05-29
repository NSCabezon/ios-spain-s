//

import UIKit
import UI

final class OnePayTransferSelectorCell: BaseViewCell {
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var leftLabel: UILabel!
    @IBOutlet private weak var rightLabel: UILabel!
    @IBOutlet private weak var rightArrow: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        self.selectionStyle = .none
        self.containerView.drawRoundedAndShadowed()
        self.leftLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .latoSemibold(size: 16)))
        self.rightLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .latoLight(size: 16)))
        self.rightArrow.image = Assets.image(named: "icnArrowRightRed")
    }
    
    func configure(left: String, right: String?, displayIcon: Bool, accessibilityIdentifierLeft: String?, accessibilityIdentifierRight: String?) {
        self.leftLabel.text = left
        self.rightLabel.text = right
        self.rightLabel.isHidden = right == nil
        self.rightArrow.isHidden = !displayIcon
        self.leftLabel.accessibilityIdentifier = accessibilityIdentifierLeft
        self.rightLabel.accessibilityIdentifier = accessibilityIdentifierRight
    }
}
