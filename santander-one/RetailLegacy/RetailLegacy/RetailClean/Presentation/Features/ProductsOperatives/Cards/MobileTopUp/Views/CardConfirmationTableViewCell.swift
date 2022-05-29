//

import UIKit

class CardConfirmationTableViewCell: BaseViewCell {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var cardImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var rightTitleLabel: UILabel!
    @IBOutlet weak var rightSubtitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .latoRegular(size: 15)))
        subtitleLabel.applyStyle(LabelStylist.pgProductSubName)
        rightTitleLabel.applyStyle(LabelStylist.pgProductSubName)
        rightSubtitleLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .latoBold(size: 18)))
        containerView.drawRoundedAndShadowed()
    }
}
