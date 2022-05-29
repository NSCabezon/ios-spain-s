import UIKit

class ConfirmationHeaderTableViewCell: BaseViewCell {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var conceptLabel: UILabel!
    @IBOutlet weak var separatorView: UIView!
    
    var amount: String? {
        set {
            amountLabel.text = newValue
            amountLabel.scaleDecimals()
        }
        get {
            return amountLabel.text
        }
    }
    
    var concept: String? {
        set {
            guard let newValue = newValue else {
                conceptLabel.isHidden = true
                return
            }
            conceptLabel.text = newValue
            conceptLabel.isHidden = newValue.isEmpty
        }
        get {
            return conceptLabel.text
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        amountLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: UIFont.latoBold(size: 30), textAlignment: .left))
        amountLabel.adjustsFontSizeToFitWidth = true
        amountLabel.minimumScaleFactor = 0.5
        conceptLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: UIFont.latoLightItalic(size: 16), textAlignment: .left))
        separatorView.backgroundColor = .lisboaGray
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        applyRoundedStyle()
    }
    
    private func applyRoundedStyle() {
        StylizerPGViewCells.applyHeaderOpenViewCellStyle(view: containerView)
    }
}
