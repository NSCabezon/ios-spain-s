import UIKit

class PortfolioProductViewCell: BaseViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    
    var title: String? {
        get {
            return titleLabel.text
        }
        set {
            titleLabel.text = newValue
        }
    }
    var subtitle: String? {
        get {
            return subtitleLabel.text
        }
        set {
            subtitleLabel.text = newValue
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
    var tapable = false {
        didSet {
            let newColor = tapable ? PortfolioProductViewCell.enabledColor : PortfolioProductViewCell.disabledColor
            titleLabel.textColor = newColor
            subtitleLabel.textColor = newColor
            amountLabel.textColor = newColor
            selectionStyle = tapable ? .default : .none
        }
    }
    var isFirstTransaction = false
    var shouldDisplayDate = false
    
    static let disabledColor = UIColor.lightGray
    static let enabledColor = UIColor.sanGreyDark
    
    override func awakeFromNib() {
        super.awakeFromNib()

        titleLabel.font = UIFont.latoSemibold(size: 16.0)
        subtitleLabel.font = UIFont.latoLight(size: 14.0)
        amountLabel.font = UIFont.latoBold(size: 24.0)
        tapable = false
    }

}
