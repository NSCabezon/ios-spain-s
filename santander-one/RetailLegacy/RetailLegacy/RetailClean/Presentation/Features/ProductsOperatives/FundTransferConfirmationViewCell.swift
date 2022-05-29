//

import UIKit

class FundTransferConfirmationViewCell: BaseViewCell {
    
    var name: String? {
        get {
            return nameLabel.text
        }
        set {
            nameLabel.text = newValue
        }
    }
    
    var amount: String? {
        get {
            return amountLabel.text
        }
        set {
            amountLabel.text = newValue
        }
    }
    
    var info: String? {
        get {
            return infoLabel.text
        }
        set {
            infoLabel.text = newValue
        }
    }
    
    @IBOutlet private weak var infoContainer: UIView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var amountLabel: UILabel!
    @IBOutlet private weak var infoLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        infoContainer.drawRoundedAndShadowed()
        infoContainer.backgroundColor = .uiWhite
        nameLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .latoBold(size: 14.0)))
        amountLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .latoBold(size: 16.0)))
        infoLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .latoBold(size: 14.0), textAlignment: NSTextAlignment.right))
        
        backgroundColor = .clear
        selectionStyle = .none
    }
}
