import UIKit

final class OperatorInfoTableViewCell: BaseViewCell {

    @IBOutlet weak var descriptionLeftLabel: UILabel!
    @IBOutlet weak var descriptionRightLabel: UILabel!
    @IBOutlet weak var bottomLabel: UILabel!
    
    func setBottomText(_ text: LocalizedStylableText) {
        bottomLabel.set(localizedStylableText: text)
    }
    
    func setDescriptionRightText(_ text: LocalizedStylableText) {
        descriptionRightLabel.set(localizedStylableText: text)
    }
    
    func setDescriptionLeftText(_ text: LocalizedStylableText) {
        descriptionLeftLabel.set(localizedStylableText: text)
    }

    func setAccessibilityIdentifiers(identifiers: OperatorInfoIdentifiers) {
        descriptionLeftLabel.accessibilityIdentifier = identifiers.leftIdentifier
        descriptionRightLabel.accessibilityIdentifier = identifiers.rightIdentifier
        bottomLabel.accessibilityIdentifier = identifiers.bottomIdentifier
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.backgroundColor = .uiBackground
        let screen = UIScreen.main
        descriptionLeftLabel.applyStyle(LabelStylist(textColor: .sanGreyDark,
                                                     font: UIFont.latoLight(size: screen.isIphone4or5 ? 12 : 14),
                                                     textAlignment: .left))
        descriptionRightLabel.applyStyle(LabelStylist(textColor: .sanGreyDark,
                                                      font: UIFont.latoLight(size: screen.isIphone4or5 ? 12 : 14),
                                                      textAlignment: .left))
        bottomLabel.applyStyle(LabelStylist(textColor: .sanGreyDark,
                                                     font: UIFont.latoLight(size: screen.isIphone4or5 ? 12 : 14),
                                                     textAlignment: .left))
    }
    
}
