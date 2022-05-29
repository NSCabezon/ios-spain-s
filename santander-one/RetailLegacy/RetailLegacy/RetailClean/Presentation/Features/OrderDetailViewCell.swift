//

import UIKit

class OrderDetailViewCell: BaseViewCell {
    @IBOutlet weak var orderDetailTitleLabel: UILabel!
    @IBOutlet weak var orderDetailInfoLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupViews()
    }
    
    private func setupViews() {
        orderDetailTitleLabel.applyStyle(LabelStylist(textColor: .sanGreyDark,
                                                      font: UIFont.latoSemibold(size: UIScreen.main.isIphone4or5 == true ? 14 : 16),
                                                      textAlignment: .left))
        orderDetailInfoLabel.applyStyle(LabelStylist(textColor: .sanGreyDark,
                                                     font: UIFont.latoLight(size: UIScreen.main.isIphone4or5 == true ? 14 : 16),
                                                     textAlignment: .right))
    }
}
