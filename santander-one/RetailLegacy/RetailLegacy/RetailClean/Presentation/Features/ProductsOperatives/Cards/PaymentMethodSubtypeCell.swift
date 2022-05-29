import UIKit

class PaymentMethodSubtypeCell: BaseViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var borderView: UIView!
    
    var subtypeText: String? {
        get {
            return titleLabel.text
        }
        set {
            titleLabel.text = newValue
        }
    }
    
    var subtypeLocalizedStylableText: LocalizedStylableText {
        get {
            return LocalizedStylableText.empty
        }
        set {
            titleLabel.set(localizedStylableText: newValue)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        selectionStyle = .none
        titleLabel.applyStyle(LabelStylist(textColor: .sanGreyMedium, font: .latoBold(size: 24)))
        setupBorder()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.applyStyle(LabelStylist(textColor: .sanGreyMedium, font: .latoBold(size: 24)))
    }
    
    func setupBorder() {
        borderView.backgroundColor = .uiWhite
        borderView.drawRoundedAndShadowed()
    }
    
    func selected(_ cellSelected: Bool) {
        titleLabel.textColor = cellSelected ? .sanRed : .sanGreyMedium
        borderView.layer.borderColor = cellSelected ? UIColor.sanRed.cgColor : UIColor.lisboaGray.cgColor
    }
    
    func setAccessibilityIdentifiers(identifier: String) {
        self.accessibilityIdentifier = identifier + "_view"
        titleLabel.accessibilityIdentifier = identifier + "_title"
    }
}
