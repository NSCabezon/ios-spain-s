import UIKit

class ImpositionViewCell: BaseViewCell {
    
    @IBOutlet weak var dateView: UIStackView!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var impositionNumberLabel: UILabel!
    @IBOutlet weak var taeLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var longSeparator: UIView!
    @IBOutlet weak var shortSeparator: UIView!

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

    var impositionNumber: LocalizedStylableText? {
        didSet {
            if let text = impositionNumber {
                impositionNumberLabel.set(localizedStylableText: text)
            } else {
                impositionNumberLabel.text = nil
            }
        }
    }
    
    var TAE: String? {
        get {
            return taeLabel.text
        }
        
        set {
            taeLabel.text = newValue
        }
    }
    
    var transactionAmount: Amount? {
        get {
            return modelTransactionAmount
        }
        
        set {
            modelTransactionAmount = newValue
            amountLabel.text = newValue?.getFormattedAmountUIWith1M()
            amountLabel.scaleDecimals()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        dayLabel.applyStyle(LabelStylist.dateDay)
        monthLabel.applyStyle(LabelStylist.dateMonth)
        impositionNumberLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .latoSemibold(size: 15.0)))
        taeLabel.applyStyle(LabelStylist(textColor: .sanGreyMedium, font: .latoRegular(size: 14.0)))
        amountLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .latoBold(size: 24.0), textAlignment: .right))
        
        shortSeparator.backgroundColor = UIColor.lisboaGray.withAlphaComponent(0.48)
        longSeparator.backgroundColor = .lisboaGray
    }
}

extension ImpositionViewCell: ProductTransactionCell {}
