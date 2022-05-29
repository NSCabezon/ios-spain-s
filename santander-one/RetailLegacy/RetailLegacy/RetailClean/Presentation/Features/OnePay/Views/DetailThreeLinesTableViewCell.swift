import UIKit

class DetailThreeLinesTableViewCell: BaseViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var separatorView: UIView!
    
    var isFirst = false
    var isLast = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.applyStyle(LabelStylist(textColor: .sanGreyMedium, font: UIFont.latoBold(size: 14)))
        amountLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: UIFont.latoBold(size: 30)))
        descriptionLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: UIFont.latoLightItalic(size: 16)))
        separatorView.backgroundColor = .lisboaGray
    }
    
    func setTitle(_ title: LocalizedStylableText) {
        titleLabel.set(localizedStylableText: title)
    }
    
    func setDescription(_ description: String?) {
        descriptionLabel.text = description
    }
    
    func setAmount(_ amount: String?) {
        amountLabel.text = amount
        amountLabel.scaleDecimals()
    }
    
    func setAccessibilityIdentifiers(titleAccessibilityIdentifier: String, amountAccessibilityIdentifier: String, descriptionAccessibilityIdentier: String) {
        titleLabel.accessibilityIdentifier = titleAccessibilityIdentifier
        amountLabel.accessibilityIdentifier = amountAccessibilityIdentifier
        descriptionLabel.accessibilityIdentifier = descriptionAccessibilityIdentier
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        applyRoundedStyle()
    }
    
    private func applyRoundedStyle() {
        if isFirst {
            StylizerPGViewCells.applyHeaderOpenViewCellStyle(view: containerView)
        } else if isLast {
            StylizerPGViewCells.applyBottomViewCellStyle(view: containerView)
        } else {
            StylizerPGViewCells.applyMiddleViewCellStyle(view: containerView)
        }
    }
}
