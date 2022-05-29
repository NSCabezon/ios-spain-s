import SwiftyJSON
import CoreDomain

public struct AmountDTO: Codable, CustomStringConvertible {
    public var value: Decimal?
    public var currency: CurrencyDTO?
    
    public init() {}
    
    public init(json : JSON) {
        self.value = DTOParser.safeDecimal("\(json["amount"].doubleValue)")
        self.currency = CurrencyDTO(currencyName: json["currency"].stringValue, currencyType: CurrencyType.parse(json["currency"].string))
    }
    
    public init(value: Decimal, currency: CurrencyDTO) {
        self.value = value
        self.currency = currency
    }
    
    public var description: String {
        guard let value = value, let currency = currency else { return "" }
        return "Amount{value=\(value), currency=\(currency)}"
    }
}

extension AmountDTO: AmountRepresentable {
    public var currencyRepresentable: CurrencyRepresentable? {
        return currency
    }
}
