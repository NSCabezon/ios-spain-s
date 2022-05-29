import UIKit

class PortfolioProductTitleViewCell: BaseViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var separatorView: UIView!
    
    var title: LocalizedStylableText? {
        didSet {
            if let text = title {
                titleLabel.set(localizedStylableText: text)
            } else {
                titleLabel.text = nil
            }
        }
    }
    
    var diferentCurrency: LocalizedStylableText? {
        didSet {
            if let text = diferentCurrency {
                amountLabel.set(localizedStylableText: text)
            } else {
                amountLabel.text = nil
            }
        }
    }
    
    var amount: String? {
        get {
            return amountLabel.text
        }
        set {
            amountLabel.text = newValue
            amountLabel.scaleDecimals()
        }
    }
    var isFirstTitle = false {
        didSet {
            separatorView.isHidden = isFirstTitle
        }
    }
    var isAmountTotal = false {
        didSet {
            if isAmountTotal {
                amountLabel.font = UIFont.latoBold(size: 24.0)
                amountLabel.scaleDecimals()
            } else {
                amountLabel.font = UIFont.latoSemibold(size: 20.0)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.textColor = .sanRed
        titleLabel.font = UIFont.latoBold(size: 15.0)
        amountLabel.textColor = .sanGreyDark
        amountLabel.font = UIFont.latoBold(size: 24.0)
        selectionStyle = .none
    }

}
