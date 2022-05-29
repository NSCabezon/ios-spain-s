import UIKit

class CardHeaderStackView: StackItemView {
    
    @IBOutlet weak var cardImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var rightInfoLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var separatorView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupViews()
    }
    
    private func setupViews() {
        separatorView.backgroundColor = .lisboaGray
        titleLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .latoRegular(size: 16)))
        subtitleLabel.applyStyle(LabelStylist(textColor: .sanGreyMedium, font: .latoRegular(size: 14)))
        rightInfoLabel.applyStyle(LabelStylist(textColor: .sanGreyMedium, font: .latoRegular(size: 14)))
        amountLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .latoBold(size: 16)))
    }
    
    func setAccessibilityIdentifiers(identifier: String) {
        cardImageView.accessibilityIdentifier = "\(identifier)_image"
        titleLabel.accessibilityIdentifier = "\(identifier)_title"
        subtitleLabel.accessibilityIdentifier = "\(identifier)_subtitle"
        rightInfoLabel.accessibilityIdentifier = "\(identifier)_rightInfo"
        amountLabel.accessibilityIdentifier = "\(identifier)_amount"
    }
}
