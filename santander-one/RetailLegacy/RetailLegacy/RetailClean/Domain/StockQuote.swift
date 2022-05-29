import SANLegacyLibrary
import Foundation

enum StockQuoteAmount {
    case diferentCurrencys
    case amount(amount: String)
}

class StockQuote: StockBase {
    
    private(set) var amount: StockQuoteAmount?
    private(set) var numberOfTitles: Int?
    private(set) var isOwned: Bool = false
    
    func updateAmount (stocks: [Stock]) {
        var currency: CurrencyDTO?
        var value: Decimal?
        var titles = 0
        for stock in stocks {
            if let amountDto = stock.getAmountDto(priceDetail: quoteDetailDto?.marketPrice, price: quoteDto.marketPrice) {
                if let currency = currency, currency.currencyType != amountDto.currency?.currencyType {
                    amount = .diferentCurrencys
                    break
                } else {
                    value = (amountDto.value ?? 0) + (value ?? 0)
                    currency = amountDto.currency
                }
            }
            titles += stock.numberOfTitles
        }
        var amountDto = AmountDTO()
        amountDto.value = value
        amountDto.currency = currency
        let amountString = Amount.createFromDTO(amountDto).getFormattedAmountUIWith1M()
        amount = StockQuoteAmount.amount(amount: amountString)
        numberOfTitles = titles
        isOwned = true
    }
    
    override func getAlias() -> String? {
        return self.name
    }
}
