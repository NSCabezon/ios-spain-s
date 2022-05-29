import UIKit

class SelectableProductViewCell: BaseViewCell {
    
    var alias: String? {
        get {
            return aliasLabel.text
        }
        set {
            aliasLabel.text = newValue
        }
    }
    
    var identifier: String? {
        get {
            return identifierLabel.text
        }
        set {
            identifierLabel.text = newValue
        }
    }
    
    var amount: String? {
        get {
            return amountLabel.text
        }
        set {
            amountLabel.text = newValue
            amountLabel.scaleDecimals()
        }
    }

    @IBOutlet private weak var infoContainer: UIView!
    @IBOutlet private weak var aliasLabel: UILabel!
    @IBOutlet private weak var identifierLabel: UILabel!
    @IBOutlet private weak var amountLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
     
        infoContainer.drawRoundedAndShadowed()
        infoContainer.backgroundColor = .uiWhite
        aliasLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .latoBold(size: 14.0)))
        identifierLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .latoLight(size: 14.0)))
        amountLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .latoBold(size: 26.0)))
        
        backgroundColor = .clear
        selectionStyle = .none
    }
    
    func setAccessibilityIdentifiers(identifier: String) {
        self.accessibilityIdentifier = identifier + "_view"
        aliasLabel.accessibilityIdentifier = identifier + "_alias"
        identifierLabel.accessibilityIdentifier = identifier + "_identifier"
        amountLabel.accessibilityIdentifier = identifier + "_amount"
    }
}
