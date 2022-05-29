import UIKit

class FinancialViewCell: BaseViewCell {

    @IBOutlet weak var content: UIView!
    @IBOutlet weak var moneyLabel: UILabel!
    @IBOutlet var moneyValue: UILabel!
    @IBOutlet weak var financingLabel: UILabel!
    @IBOutlet weak var financingValue: CoachmarkUILabel!
    @IBOutlet weak var bottomSeparator: UIView!
    
    //Margins
    @IBOutlet weak var containerRightMargin: NSLayoutConstraint!
    
    var financingLabelCoachmarkId: CoachmarkIdentifier? {
        get {
            return financingValue.coachmarkId
        } set {
            financingValue.coachmarkId = newValue
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        moneyLabel.applyStyle(LabelStylist.pgDefaultHeaderLabel)
        financingLabel.applyStyle(LabelStylist.pgDefaultHeaderLabel)

        let device = UIScreen.main.isIphone4or5
        
        let moneyFontSize = device ? UIFont.latoBold(size: 22) : UIFont.latoBold(size: 27)
        moneyValue.applyStyle(LabelStylist(textColor: .sanGreyDark, font: moneyFontSize))
        let financingFontSize = device ? UIFont.latoBold(size: 19) : UIFont.latoBold(size: 23)
        (financingValue as UILabel).applyStyle(LabelStylist(textColor: .sanGreyDark, font: financingFontSize))
        bottomSeparator.backgroundColor = .lisboaGray
        content.backgroundColor = .uiWhite
        
        selectionStyle = .none
        
        if device { containerRightMargin.constant = 25 }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }

    func setYourMoneyAmount(_ moneyAmount: String) {
        moneyValue.text = moneyAmount
        moneyValue.scaleDecimals()
    }
    
    func setFinancingAmount(_ financingAmount: String) {
        financingValue.text = financingAmount
        financingValue.scaleDecimals()
    }
    
    func setYourMoneyMultipleCurrency(_ multipleCurrency: LocalizedStylableText) {
        moneyValue.set(localizedStylableText: multipleCurrency)
    }
    
    func setFinancingAmountMultipleCurrency(_ multipleCurrency: LocalizedStylableText) {
        financingValue.set(localizedStylableText: multipleCurrency)
    }
    
    func setLabelText(_ moneyText: LocalizedStylableText, _ financingText: LocalizedStylableText) {
        moneyLabel.set(localizedStylableText: moneyText)
        financingLabel.set(localizedStylableText: financingText)
    }
}
