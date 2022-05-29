import UIKit

class SubscriptionOperativeLabelTableViewCell: BaseViewCell {
    
    var advise: String? {
        get {
            return adviseLabel.text
        }
        set {
            adviseLabel.text = newValue
        }
    }

    @IBOutlet weak var adviseLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        adviseLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .latoRegular(size: 12)))
        adviseLabel.numberOfLines = 0
        adviseLabel.textAlignment = .center
        backgroundColor = .clear
        selectionStyle = .none
    }
    
}
