import UIKit

class TipTableViewCell: BaseViewCell {
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var borderView: UIView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        iconImage.image = nil
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        backgroundColor = .uiBackground
        contentView.backgroundColor = .uiBackground
        titleLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: UIFont.latoSemibold(size: 16.0), textAlignment: .left))
        descriptionLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: UIFont.latoLight(size: 14.0), textAlignment: .left))
        borderView.drawRoundedAndShadowed()
    }
    
    func set(title: String?) {
        titleLabel.text = title
    }
    
    func set(description: String?) {
        descriptionLabel.text = description
    }
    
    func set(image: UIImage) {
        iconImage.image = image
    }
}
