import UIKit
import UI

class FavoriteTransferRecipientViewCell: BaseViewCell {
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var countryLabel: UILabel!
    @IBOutlet private weak var currencyLabel: UILabel!
    @IBOutlet weak var worldImage: UIImageView!
    @IBOutlet weak var billImage: UIImageView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var separatorView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        separatorView.backgroundColor = .lisboaGray
        containerView.drawRoundedAndShadowed()
        containerView.backgroundColor = .uiWhite
        titleLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .latoSemibold(size: 16.0)))
        subtitleLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .latoLight(size: 16.0)))
        subtitleLabel.minimumScaleFactor = 0.5
        subtitleLabel.adjustsFontSizeToFitWidth = true
        countryLabel.applyStyle(LabelStylist(textColor: .sanGreyMedium, font: .latoRegular(size: 14.0)))
        currencyLabel.applyStyle(LabelStylist(textColor: .sanGreyMedium, font: .latoRegular(size: 14.0)))
        
        backgroundColor = .clear
        selectionStyle = .none
        worldImage.image = Assets.image(named: "icnWorldRetail")
        billImage.image = Assets.image(named: "icnBillRetail")
    }
    
    func setTitle(_ title: LocalizedStylableText) {
        titleLabel.set(localizedStylableText: title)
    }
    
    func setSubtitle(_ subtitle: LocalizedStylableText) {
        subtitleLabel.set(localizedStylableText: subtitle)
    }
    
    func setCountry(_ country: LocalizedStylableText) {
        countryLabel.set(localizedStylableText: country)
    }

    func setCurrency(_ currency: LocalizedStylableText) {
        currencyLabel.set(localizedStylableText: currency)
    }

}
