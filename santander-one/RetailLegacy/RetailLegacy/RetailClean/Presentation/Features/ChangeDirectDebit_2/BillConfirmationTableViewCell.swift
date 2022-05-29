import UIKit

class BillConfirmationTableViewCell: BaseViewCell {
    @IBOutlet private weak var infoContainer: UIView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var identifierLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        infoContainer.drawRoundedAndShadowed()
        infoContainer.backgroundColor = .uiWhite
        backgroundColor = .clear
        selectionStyle = .none
    }
    
    override func configureStyle() {
        super.configureStyle()
        nameLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .latoBold(size: 16.0)))
        identifierLabel.applyStyle(LabelStylist(textColor: .sanGreyMedium, font: .latoSemibold(size: 16.0)))
    }

    func set(name: String, identifier: String) {
        nameLabel.text = name
        identifierLabel.text = identifier
    }
}
