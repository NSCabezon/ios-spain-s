import UIKit

struct StockSummaryData {
    let ticker: String?
    let price: String?
    let variation: String?
    let comparison: ComparisonResult
    let isShareable = false
}

extension StockSummaryData: SummaryItemData {
    func createSummaryItem() -> SummaryItem {
        return SummaryItemViewConfigurator<StockSummaryItemView, StockSummaryData>(data: self)
    }
    
    var description: String {
        return ""
    }
}

class StockSummaryItemView: UIView {

    @IBOutlet weak var tickerLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var variationImage: UIImageView!
    @IBOutlet weak var variationLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        tickerLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .latoBold(size: 16.0)))
        priceLabel.applyStyle(LabelStylist(textColor: .uiBlack, font: .latoMedium(size: 35.0)))
        variationLabel.applyStyle(LabelStylist(textColor: .uiBlack, font: .latoBold(size: 16.0)))
        
        backgroundColor = .clear
    }

}

extension StockSummaryItemView: ConfigurableSummaryItemView {
    func configure(data: StockSummaryData) {
        tickerLabel.text = data.ticker
        priceLabel.text = data.price
        priceLabel.scaleDecimals()
        variationImage.setVariation(variation: data.variation, compareZero: data.comparison)
        variationLabel.text = data.variation
        variationLabel.setVariation(variation: data.variation, compareZero: data.comparison)
    }
}
