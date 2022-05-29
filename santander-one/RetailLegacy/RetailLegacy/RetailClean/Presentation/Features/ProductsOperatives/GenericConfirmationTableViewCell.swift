import UIKit

class GenericConfirmationTableViewCell: BaseViewCell {
    
    var name: String? {
        get {
            return nameLabel.text
        }
        set {
            nameLabel.text = newValue
        }
    }
    
    var identifier: String? {
        get {
            return identifierLabel.text
        }
        set {
            identifierLabel.text = newValue
            identifierLabel.isHidden = identifierLabel.text?.isEmpty ?? true
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
    
    var amountInfo: LocalizedStylableText? {
        didSet {
            if let text = amountInfo {
                amountInfoLabel.set(localizedStylableText: text)
                amountInfoLabel.isHidden = text.text.isEmpty
            } else {
                amountInfoLabel.text = nil
                amountInfoLabel.isHidden = true
            }
        }
    }

    @IBOutlet private weak var infoContainer: UIView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var identifierLabel: UILabel!
    @IBOutlet private weak var amountLabel: UILabel!
    @IBOutlet private weak var amountInfoLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        infoContainer.drawRoundedAndShadowed()
        infoContainer.backgroundColor = .uiWhite
        nameLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .latoBold(size: 14.0)))
        identifierLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .latoLight(size: 14.0)))
        amountLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .latoBold(size: 16.0)))
        amountInfoLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .latoLight(size: 14.0)))
        identifier = nil
        amountInfo = nil
        
        backgroundColor = .clear
        selectionStyle = .none
    }
    
    func setAccessibilityIdentifiers(identifiers: AccountConfirmationIdentifiers) {
        amountLabel.accessibilityIdentifier = identifiers.amount
        nameLabel.accessibilityIdentifier = identifiers.name
        identifierLabel.accessibilityIdentifier = identifiers.identifier
        amountInfoLabel.accessibilityIdentifier = identifiers.amountInfo
    }
}
