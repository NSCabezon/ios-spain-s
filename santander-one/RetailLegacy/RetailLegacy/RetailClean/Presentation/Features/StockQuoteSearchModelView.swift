//

import Foundation
import CoreFoundationLib

class StockQuoteSearchModelView: TableModelViewItem<StockQuoteSearchViewCell> {
    private let quote: StockQuote
    var shouldDisplayDate = false
    var isFirstTransaction = false
    
    init(quote: StockQuote, dependencies: PresentationComponent) {
        self.quote = quote
        super.init(dependencies: dependencies)
    }
    
    override var identifier: String {
        return quote.isOwned ? "StockSearchViewCell": "StockQuoteSearchViewCell"
    }
    
    override func bind(viewCell: StockQuoteSearchViewCell) {
        viewCell.setState(state: quote.state)
        viewCell.setTicker(ticker: quote.ticker)
        var completeDate = ""
        if let date = dependencies.timeManager.toString(date: quote.priceDate, outputFormat: TimeFormat.d_MMM_yyyy) {
            completeDate = date
        }
        if let time = dependencies.timeManager.toString(date: quote.priceTime, outputFormat: TimeFormat.HHmm) {
            if !completeDate.isEmpty {
                completeDate.append(" - ")
            }
            completeDate.append(time)
            
        }
        viewCell.setDate(date: completeDate.lowercased())
        viewCell.setName(name: quote.stockName)
        viewCell.setPrice(price: quote.priceTitle)
        viewCell.setVariation(variation: quote.variation, compareZero: quote.variationCompare)
        let numberOfTitles = quote.numberOfTitles ?? 0
        let valueFormatted = formatterForRepresentation(.decimal(decimals: 0)).string(from: NSNumber(value: numberOfTitles)) ?? ""
        let titles = dependencies.stringLoader.getQuantityString("stocksDetail_text_totalTitles", numberOfTitles, [StringPlaceholder(StringPlaceholder.Placeholder.number, valueFormatted)])
        viewCell.setTitles(titles: titles)
        if let typeAmount = quote.amount {
            switch typeAmount {
            case .diferentCurrencys:
                viewCell.setAmountDiferentCurrencies(amount: dependencies.stringLoader.getString("pgBasket_label_differentCurrency"))
            case .amount(let amount):
                viewCell.setAmount(amount: amount)
            }
        } else {
            viewCell.setAmount(amount: nil)
        }
    }
}

// MARK: - DateProvider

extension StockQuoteSearchModelView: DateProvider {
    
    var transactionDate: Date? {
        return nil
    }
}
