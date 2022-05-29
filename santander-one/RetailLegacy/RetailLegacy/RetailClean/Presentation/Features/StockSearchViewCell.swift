//

import UIKit

class StockSearchViewCell: StockQuoteSearchViewCell {
    
    @IBOutlet private weak var titlesLabel: UILabel!
    @IBOutlet private weak var amountLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        titlesLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .latoRegular(size: 13), textAlignment: .left))
        amountLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .latoBold(size: 16), textAlignment: .right))
    }
    
    override func setTitles(titles: LocalizedStylableText?) {
        if let text = titles {
            titlesLabel.set(localizedStylableText: text)
        } else {
            titlesLabel.text = nil
        }
    }
    
    override func setAmount(amount: String?) {
        amountLabel.text = amount
    }
    
    override func setAmountDiferentCurrencies(amount: LocalizedStylableText?) {
        if let text = amount {
            amountLabel.set(localizedStylableText: text)
        } else {
            amountLabel.text = nil
        }
    }
}
