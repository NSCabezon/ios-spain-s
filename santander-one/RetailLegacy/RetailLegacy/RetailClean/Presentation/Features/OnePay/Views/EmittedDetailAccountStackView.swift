import UIKit

class EmittedDetailAccountStackView: StackItemView {
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
    @IBOutlet private weak var infoContainer: UIView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var identifierLabel: UILabel!
    @IBOutlet private weak var amountLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        infoContainer.drawRoundedAndShadowed()
        infoContainer.backgroundColor = .uiWhite
        nameLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .latoBold(size: 14.0)))
        identifierLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .latoLight(size: 14.0)))
        amountLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .latoBold(size: 16.0)))
        identifier = nil
        backgroundColor = .clear
    }
}
