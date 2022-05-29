import SANLegacyLibrary
import Foundation

class Stock: StockBase {
    public let dto: StockDTO
    private(set) var amount: String?

    init(dto: StockDTO) {
        self.dto = dto
        super.init(dto.stockQuoteDTO)
    }
    
    var numberOfTitles: Int {
        return dto.sharesCount ?? 0
    }
    
    override func calculations() {
        super.calculations()
        setAmount()
    }
    
    private func setAmount () {
        if let amountDto = getAmountDto() {
            amount = Amount.createFromDTO(amountDto).getFormattedAmountUIWith1M()
        } else {
            amount = Amount.zero().getFormattedAmountUIWith1M()
        }
    }
    
    func getAmountDto(priceDetail: AmountDTO? = nil, price: AmountDTO? = nil) -> AmountDTO? {
        guard let marketPrice = priceDetail ?? quoteDetailDto?.marketPrice ?? price ?? quoteDto.marketPrice, let value = marketPrice.value else {
            return nil
        }
        let currency = marketPrice.currency
        if "%" == currency?.getSymbol() {
            return dto.position
        } else {
            let numSecurities = Decimal(numberOfTitles)
            let position = numSecurities * value
            var amountDto = AmountDTO()
            amountDto.value = position
            amountDto.currency = currency
            return amountDto
        }
    }
    
    func getPosition(marketPrice: Amount?) -> Amount {
        let auxMarketPrice = self.quoteDetailDto?.marketPrice != nil ? Amount.createFromDTO(self.quoteDetailDto?.marketPrice!) : marketPrice

        guard let currentMarketPrice = auxMarketPrice, currentMarketPrice.value != nil else {
            return Amount.zero()
        }
        
        if currentMarketPrice.currency?.getSymbol() == "%" {
            return Amount.createFromDTO(dto.position)
        } else {
            if let value = currentMarketPrice.value, let sharesCount = dto.sharesCount, let currency = currentMarketPrice.currency {
                let position = (value as NSDecimalNumber).multiplying(by: NSDecimalNumber(value: sharesCount))
                return Amount.createFromDTO(AmountDTO(value: position as Decimal, currency: currency))
            }
        }
        
        return Amount.zero()
    }
}

extension Stock: Equatable {}
extension Stock: OperativeParameter {}

func == (lhs: Stock, rhs: Stock) -> Bool {
    return lhs.getAlias() == rhs.getAlias() &&
        lhs.getDetailUI() == rhs.getDetailUI() &&
        lhs.getAmountValue() == rhs.getAmountValue() &&
        lhs.getTipoInterv() == rhs.getTipoInterv()
}

extension Array where Element == Stock {
    
    func filter(byLocalId localId: String) -> [Stock] {
        return filter { $0.getLocalId() == localId }
    }
    
    func numberOfTitles(forLocalId localId: String) -> Int {
        return filter(byLocalId: localId)
            .map { $0.numberOfTitles }
            .reduce(0, +)
    }
    
}
