import UIKit

class DetailCardView: BaseHeader, ViewCreatable {
    @IBOutlet weak var cardImageView: UIImageView!
    @IBOutlet weak var cardNumberLabel: UILabel!
    @IBOutlet weak var cardExpirationLabel: UILabel!
    @IBOutlet weak var cardUserNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupViews()
    }
    
    func setupViews() {
        let screen = UIScreen.main
        cardNumberLabel.applyStyle(LabelStylist(textColor: .uiWhite, font: .halterRegular(size: screen.isIphone4or5 ? 8.0 : 10.0), textAlignment: .center))
        cardExpirationLabel.applyStyle(LabelStylist(textColor: .uiWhite, font: .halterRegular(size: screen.isIphone4or5 ? 6.0 : 7.0), textAlignment: .center))
        cardUserNameLabel.applyStyle(LabelStylist(textColor: .uiWhite, font: .halterRegular(size: screen.isIphone4or5 ? 7.0 : 8.0), textAlignment: .left))
    }
    
    func applyShadow() {
        cardNumberLabel.addShadow(offset: CGSize(width: 1, height: 1), radius: 0, color: .uiBlack, opacity: 0.7)
        cardExpirationLabel.addShadow(offset: CGSize(width: 1, height: 1), radius: 0, color: .uiBlack, opacity: 0.7)
        cardUserNameLabel.addShadow(offset: CGSize(width: 1, height: 1), radius: 0, color: .uiBlack, opacity: 0.7)
    }
    
    func prepaidCardConfig() {
        cardNumberLabel.isHidden = true
        cardExpirationLabel.isHidden = true
        cardUserNameLabel.isHidden = true
    }
}
