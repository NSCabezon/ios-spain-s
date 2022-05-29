import SANLegacyLibrary
import Foundation
import CoreFoundationLib

enum StockState: String {
    case loading
    case done
    case error
    
    public func fromString(rawValue: String) -> StockState {
        switch rawValue {
        case "loading":
            return .loading
        case "done":
            return .done
        case "error":
            return .error
        default:
            return .loading
        }
    }
}

class StockBase: GenericProduct {
    private(set) var quoteDto: StockQuoteDTO
    private(set) var quoteDetailDto: StockQuoteDetailDTO?
    private(set) var name: String?
    private(set) var price: Amount?
    private(set) var priceTitle: String = ""
    private(set) var variation: String?
    private(set) var variationPrice: Amount?
    private(set) var variationCompare: ComparisonResult = .orderedSame
    var state: StockState = .loading
    
    init(_ quoteDto: StockQuoteDTO) {
        self.quoteDto = quoteDto
        super.init()
        calculations()
    }
    
    var priceDate: Date? {
        return quoteDetailDto?.priceDate ?? quoteDto.priceDate
    }
    
    var priceTime: Date? {
       return quoteDetailDto?.priceTime ?? quoteDto.priceTime
    }
    
    var ticker: String? {
        return quoteDto.ticker
    }
    
    var stockName: String? {
        return quoteDetailDto?.name
    }
    
    override func getAmountValue() -> Decimal? {
        return quoteDto.marketPrice?.value
    }
    
    override func getAmountCurrency() -> CurrencyDTO? {
        return quoteDto.marketPrice?.currency
    }
    
    func setQuoteDetailDto (quoteDetailDto: StockQuoteDetailDTO) {
        self.quoteDetailDto = quoteDetailDto
        calculations()
    }
    
    func getLocalId() -> String? {
        return quoteDto.getLocalId()
    }
    
    func getStockCode() -> String? {
        return quoteDto.stockCode
    }
    
    func getIdentificationNumber() -> String? {
        return quoteDto.identificationNumber
    }
    
    func calculations() {
        setName()
        setVariation()
        setPrice()
    }
    
    private func setName () {
        if let stockName = quoteDetailDto?.name {
            if let ticker = quoteDto.ticker {
                name = "\(stockName) (\(ticker))"
            } else {
                name = stockName
            }
        } else if let ticker = quoteDto.ticker {
            name = "(\(ticker))"
        }
    }
    
    private func setPrice () {
        price = Amount.createFromDTO(quoteDetailDto?.marketPrice ?? quoteDto.marketPrice)
        
        if let price = price {
            priceTitle = price.getFormattedAmountUIWith1M()
        }
    }
    
    private func setVariation () {
        variation = nil
        variationCompare = .orderedSame
        if let values = getVariationValues() {
            let value = (100 * (values.newValue / values.oldValue - 1))
            if checkValidNumber(value: value) {
                let decimal = NSDecimalNumber(decimal: value)
                variation = formatterForRepresentation(.decimal(decimals: 2)).string(from: decimal) ?? "0"
                if let price = price {
                    variationPrice = Amount.createWith(value: values.newValue - values.oldValue, amount: price)
                }
                if value == 0 {
                    variationCompare = .orderedSame
                } else if value < 0 {
                    variationCompare = .orderedDescending
                } else {
                    variationCompare = .orderedAscending
                }
            }
        }
    }
    
    private func checkValidNumber (value: Decimal) -> Bool {
        return !value.isNaN && !value.isInfinite
    }
    
    private func getVariationValues () -> (oldValue: Decimal, newValue: Decimal)? {
        guard let quote = quoteDetailDto, let oldValue = getVariationValue(value: quote.closingPrice), let newValue = getVariationValue(value: quote.marketPrice) else {
            return nil
        }
        guard checkCurrencies(oldCurrency: quote.closingPrice?.currency, newCurrency: quote.marketPrice?.currency) else {
            return nil
        }
        return (oldValue: oldValue, newValue: newValue)
    }
    
    private func checkCurrencies (oldCurrency: CurrencyDTO?, newCurrency: CurrencyDTO?) -> Bool {
        return oldCurrency?.currencyName == newCurrency?.currencyName && oldCurrency?.currencyType == newCurrency?.currencyType
    }
    
    private func getVariationValue (value: AmountDTO?) -> Decimal? {
        guard let amount = value?.value, amount != 0, checkValidNumber(value: amount) else {
            return nil
        }
        return amount
    }
}
