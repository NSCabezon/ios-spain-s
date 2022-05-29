import UIKit
import UI

class LandingPushHeaderTableViewCell: BaseViewCell {
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var commerceLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var hourLabel: UILabel!
    @IBOutlet weak var cardImageView: UIImageView!
    @IBOutlet weak var cardNameLabel: UILabel!
    @IBOutlet weak var cardPanLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var cardContainerView: UIView!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var backgroundHeaderImageView: UIImageView!
    
    func setImage(image: String?) {
        cardImageView.image = Assets.image(named: image ?? "")
    }
    
    func setAlertName(alertName: LocalizedStylableText) {
        categoryLabel.set(localizedStylableText: alertName.uppercased())
    }
    
    func setCommerce(commerce: String?) {
        commerceLabel.text = commerce
    }
    
    func setAmount(amount: String?) {
        amountLabel.text = amount
        amountLabel.scaleDecimals()
    }
    
    func setDay(day: String?) {
        dayLabel.text = day
    }
    
    func setHour(hour: String?) {
        hourLabel.text = hour
    }
    
    func setCardName(name: String) {
        cardNameLabel.text = name
    }
    
    func setCardPan(cardPan: String?) {
        cardPanLabel.text = cardPan
    }
    
    func setUserName(userName: String?) {
        userNameLabel.text = userName
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        separatorView.backgroundColor = .lisboaGray
        
        categoryLabel.applyStyle(LabelStylist(textColor: .uiWhite, font: .santanderHeadlineRegular(size: 14.0), textAlignment: .center))
        commerceLabel.applyStyle(LabelStylist(textColor: .uiWhite, font: .santanderHeadlineBold(size: 22.0), textAlignment: .center))
        amountLabel.applyStyle(LabelStylist(textColor: .uiWhite, font: .santanderTextLight(size: 60.0), textAlignment: .center))
        dayLabel.applyStyle(LabelStylist(textColor: .uiWhite, font: .santanderTextRegular(size: 14.0)))
        hourLabel.applyStyle(LabelStylist(textColor: .uiWhite, font: .santanderTextRegular(size: 14.0)))
        cardNameLabel.applyStyle(LabelStylist(textColor: .uiWhite, font: .halterRegular(size: 8.0)))
        addTextShadow(cardNameLabel)
        cardPanLabel.applyStyle(LabelStylist(textColor: .uiWhite, font: .halterRegular(size: 10.0)))
        addTextShadow(cardPanLabel)
        userNameLabel.applyStyle(LabelStylist(textColor: .uiWhite, font: .halterRegular(size: 8.0)))
        addTextShadow(userNameLabel)
        if #available(iOS 11.0, *) {
            topConstraint.constant = UIApplication.shared.delegate?.window??.safeAreaInsets.top ?? 0
        }
        setupContainerShadow()
        backgroundHeaderImageView.image = Assets.image(named: "imgHeaderBackground")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        cardContainerView.layer.cornerRadius = 8
        cardImageView.layer.cornerRadius = 8
    }
    
    private func addTextShadow(_ label: UILabel) {
        label.layer.shadowRadius = 1
        label.layer.shadowOpacity = 1
        label.layer.shadowColor = UIColor.uiBlack.cgColor
        label.layer.shadowOffset = CGSize(width: 1, height: 1)
    }
    
    private func setupContainerShadow() {
        cardContainerView.layer.shadowColor = UIColor.uiBlack.cgColor
        cardContainerView.layer.shadowOffset = CGSize(width: 0, height: -10)
        cardContainerView.layer.shadowRadius = 6
        cardContainerView.layer.masksToBounds = false
        cardContainerView.layer.shadowOpacity = 0.5
    }

}
