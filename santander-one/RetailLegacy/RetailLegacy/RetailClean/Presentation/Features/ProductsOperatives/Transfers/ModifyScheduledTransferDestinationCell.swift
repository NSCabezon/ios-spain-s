//

import UIKit
import UI

class ModifyScheduledTransferDestinationCell: BaseViewCell {
    
    // MARK: - Outlets
    
    @IBOutlet weak var beneficiary: UILabel!
    @IBOutlet weak var periodicity: UILabel!
    @IBOutlet weak var periodicityDetail: UILabel!
    @IBOutlet weak var country: UILabel!
    @IBOutlet weak var currency: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var worldImage: UIImageView!
    @IBOutlet weak var billImage: UIImageView!
    
    // MARK: - Public methods
   
    override func awakeFromNib() {
        super.awakeFromNib()
        separatorView.backgroundColor = .lisboaGray
        containerView.drawRoundedAndShadowed()
        containerView.backgroundColor = .uiWhite
        beneficiary.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .latoSemibold(size: 16.0)))
        periodicity.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .latoLight(size: 16.0)))
        periodicityDetail.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .latoLight(size: 16.0), textAlignment: .right))
        country.applyStyle(LabelStylist(textColor: .sanGreyMedium, font: .latoRegular(size: 14.0)))
        currency.applyStyle(LabelStylist(textColor: .sanGreyMedium, font: .latoRegular(size: 14.0)))
        backgroundColor = .clear
        selectionStyle = .none
        worldImage.image = Assets.image(named: "icnWorldRetail")
        billImage.image = Assets.image(named: "icnBillRetail")
    }
}
