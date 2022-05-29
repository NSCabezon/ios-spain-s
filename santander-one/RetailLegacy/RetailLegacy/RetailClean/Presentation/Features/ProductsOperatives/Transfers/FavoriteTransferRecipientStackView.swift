import UIKit
import UI

class FavoriteTransferRecipientStackView: StackItemView {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var countryLabel: UILabel!
    @IBOutlet private weak var currencyLabel: UILabel!
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var separatorView: UIView!
    @IBOutlet weak var worldImage: UIImageView!
    @IBOutlet weak var billImage: UIImageView!
    
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
        worldImage.image = Assets.image(named: "icnWorldRetail")
        billImage.image = Assets.image(named: "icnBillRetail")
    }
    
    func setTitle(_ title: LocalizedStylableText) {
        titleLabel.set(localizedStylableText: title)
        titleLabel.accessibilityIdentifier =  "newSendOnePay_favorite_title_\(title)"
    }
    
    func setSubtitle(_ subtitle: LocalizedStylableText) {
        subtitleLabel.set(localizedStylableText: subtitle)
        subtitleLabel.accessibilityIdentifier =  "newSendOnePay_favorite_subtitle_\(subtitle)"
    }
    
    func setCountry(_ country: LocalizedStylableText) {
        countryLabel.set(localizedStylableText: country)
        countryLabel.accessibilityIdentifier =  "newSendOnePay_favorite_country_\(country)"
    }
    
    func setCurrency(_ currency: LocalizedStylableText) {
        currencyLabel.set(localizedStylableText: currency)
        currencyLabel.accessibilityIdentifier =  "newSendOnePay_favorite_currency_\(currency)"
    }
    
}
