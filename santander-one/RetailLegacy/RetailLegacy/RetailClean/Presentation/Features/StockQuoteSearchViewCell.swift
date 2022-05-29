//

import UIKit

class StockQuoteSearchViewCell: BaseViewCell {
    
    @IBOutlet private weak var tickerLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var priceLabel: UILabel!
    @IBOutlet private weak var variationLabel: UILabel!
    @IBOutlet private weak var variationImage: UIImageView!
    @IBOutlet private var toVariationConstarint: NSLayoutConstraint!
    @IBOutlet private weak var borderView: UIView!
    @IBOutlet private weak var loadingView: UIImageView!
    private let indexLabel = "[index]"

    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none
        let screen = UIScreen.main
        tickerLabel.applyStyle(LabelStylist(textColor: .sanGreyMedium, font: .latoBold(size: screen.isIphone4or5 ? 13 : 14), textAlignment: .left))
        dateLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .latoRegular(size: 13), textAlignment: .right))
        nameLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .latoBold(size: screen.isIphone4or5 ? 13 : 14), textAlignment: .left))
        priceLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .latoBold(size: screen.isIphone4or5 ? 15 : 16), textAlignment: .right))
        variationLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .latoRegular(size: screen.isIphone4or5 ? 15 : 16), textAlignment: .center))
        borderView.drawRoundedAndShadowed()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    // MARK: - Class Methods
    
    func setTicker(ticker: String?) {
        tickerLabel.text = ticker
    }
    
    func setDate(date: String?) {
        dateLabel.text = date
    }
    
    func setName(name: String?) {
        nameLabel.text = name
    }
    
    func setPrice(price: String?) {
        priceLabel.text = price
    }
    
    func setState (state: StockState) {
        switch state {
        case .loading:
            showLoading()
        case .error, .done:
            hideLoading()
        }
    }
    
    func setVariation (variation: String?, compareZero: ComparisonResult) {
        variationImage.setVariation(variation: variation, compareZero: compareZero)
        variationLabel.setVariation(variation: variation, compareZero: compareZero, withParenthesis: true)
        toVariationConstarint.constant = (variation == nil) ? -19 : 2
    }
    
    func setTitles(titles: LocalizedStylableText?) {
    }
    
    func setAmount(amount: String?) {
    }
    
    func setAmountDiferentCurrencies(amount: LocalizedStylableText?) {
    }
    
    // MARK: - Private Methods
    
    private func showLoading () {
        loadingView.setSecondaryLoader(scale: 2.0)
        loadingView.isHidden = false
    }
    
    private func hideLoading () {
        loadingView.removeLoader()
        loadingView.isHidden = true
    }
}
