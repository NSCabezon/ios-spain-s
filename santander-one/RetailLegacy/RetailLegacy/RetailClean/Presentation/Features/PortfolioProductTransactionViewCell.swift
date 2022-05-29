import UIKit

class PortfolioProductTransactionViewCell: BaseViewCell, ProductTransactionCell {
    
    @IBOutlet weak var dateView: UIStackView!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var conceptLabel: UILabel!
    @IBOutlet weak var transactionAmountLabel: UILabel!
    @IBOutlet weak var shortSeparator: UIView!
    @IBOutlet weak var longSeparator: UIView!
    
    var modelTransactionAmount: Amount?
    
    var isFirstTransaction: Bool = false {
        didSet {
            showSeparator(showsDate)
        }
    }
    var showsDate: Bool = false {
        didSet {
            dateView.isHidden = !showsDate
            showSeparator(showsDate)
        }
    }

    var day: String? {
        get {
            return dayLabel.text
        }
        set {
            dayLabel.text = newValue
        }
    }

    var month: String? {
        get {
            return monthLabel.text
        }
        set {
            monthLabel.text = newValue
        }
    }
    
    var concept: String? {
        get {
            return conceptLabel.text
        }
        
        set {
            conceptLabel.text = newValue?.camelCasedString
        }
    }
    
    var transactionAmount: Amount? {
        get {
            return modelTransactionAmount
        }
        
        set {
            modelTransactionAmount = newValue
            transactionAmountLabel.text = newValue?.getFormattedAmountUIWith1M()
            transactionAmountLabel.scaleDecimals()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        dayLabel.applyStyle(LabelStylist.dateDay)
        monthLabel.applyStyle(LabelStylist.dateMonth)
        conceptLabel.applyStyle(LabelStylist.conceptTitleTransaction)
        transactionAmountLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .latoBold(size: 22.0), textAlignment: .right))
        
        shortSeparator.backgroundColor = UIColor.lisboaGray.withAlphaComponent(0.48)
        longSeparator.backgroundColor = .lisboaGray
    }
}
