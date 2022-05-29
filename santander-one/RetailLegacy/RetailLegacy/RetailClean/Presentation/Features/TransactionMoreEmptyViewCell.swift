import UIKit

class TransactionMoreEmptyViewCell: TransactionMoreViewCell {
    @IBOutlet weak var infoLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        infoLabel.applyStyle(LabelStylist(textColor: .sanGreyMedium, font: UIFont.latoRegular(size: 14), textAlignment: .center))
    }

    func set(info: LocalizedStylableText) {
        infoLabel.set(localizedStylableText: info)
    }
    
    func setAccessibilityIdentifiers(identifier: String) {
        self.accessibilityIdentifier = identifier + "_view"
        infoLabel.accessibilityIdentifier = identifier + "_label"
    }
}
