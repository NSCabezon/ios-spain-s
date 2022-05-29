import Foundation

class StockBaseHeaderViewModel: HeaderViewModel<StockBaseHeaderView> {
    let ticker: String?
    let priceDate: String?
    let priceVariation: String?
    let variation: String?
    let price: String?
    let compareZero: ComparisonResult?
    
    init(ticker: String?, priceDate: String?, priceVariation: String?, variation: String?, price: String?, compareZero: ComparisonResult?) {
        self.ticker = ticker
        self.priceDate = priceDate
        self.priceVariation = priceVariation
        self.variation = variation
        self.price = price
        self.compareZero = compareZero
    }
    
    override func configureView(_ view: StockBaseHeaderView) {
        view.tickerLabel.text = ticker
        view.priceDateLabel.text = priceDate
        view.priceVariationLabel.text = priceVariation
        if let comparison = compareZero {
            view.variationLabel.setVariation(variation: variation, compareZero: comparison)
            view.variationImageView.setVariation(variation: variation, compareZero: comparison)
        } else {
            view.variationLabel.text = variation
            view.variationImageView.image = nil
        }
        view.priceLabel.text = price
    }
}
