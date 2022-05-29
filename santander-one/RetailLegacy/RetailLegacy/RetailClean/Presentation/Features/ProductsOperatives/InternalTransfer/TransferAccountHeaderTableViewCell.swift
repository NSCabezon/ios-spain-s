//

import UIKit

class TransferAccountHeaderTableViewCell: BaseViewCell {
    
    // MARK: - Public attributes
    
    var amount: String? {
        set {
            amountLabel.text = newValue
            amountLabel.scaleDecimals()
        }
        get {
            return amountLabel.text
        }
    }
    
    var destinationAccount: String? {
        set {
            destinationAccountLabel.text = newValue
        }
        get {
            return destinationAccountLabel.text
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
    
    // MARK: - Private attributes
    
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var amountLabel: UILabel!
    @IBOutlet private weak var destinationAccountLabel: UILabel!
    @IBOutlet private weak var conceptLabel: UILabel!
    
    // MARK: - Public methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        selectionStyle = .none
        contentView.backgroundColor = .uiBackground
        amountLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: UIFont.latoBold(size: 30), textAlignment: .left))
        amountLabel.adjustsFontSizeToFitWidth = true
        amountLabel.minimumScaleFactor = 0.5
        destinationAccountLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: UIFont.latoLight(size: 16), textAlignment: .left))
        destinationAccountLabel.adjustsFontSizeToFitWidth = true
        destinationAccountLabel.minimumScaleFactor = 0.7
        conceptLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: UIFont.latoLightItalic(size: 16), textAlignment: .left))
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        StylizerPGViewCells.applyHeaderOpenViewCellStyle(view: containerView)
    }
}
