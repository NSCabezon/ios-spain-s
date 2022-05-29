
import CoreDomain

public struct CurrencyDTO: Codable {
    public let currencyName: String
    public let currencyType: CurrencyType
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let currency = try container.decode(String.self)
        self.currencyName = currency
        self.currencyType = CurrencyType.parse(currency)
    }
    
    public static func create(_ currencyName: String) -> CurrencyDTO {
        return CurrencyDTO(currencyName: currencyName, currencyType: CurrencyType.parse(currencyName))
    }

    public static func create(_ currencyType: CurrencyType) -> CurrencyDTO {
        return CurrencyDTO(currencyName: currencyType.name, currencyType: currencyType)
    }

    public init(currencyName: String, currencyType: CurrencyType) {
        self.currencyName = currencyName
        self.currencyType = currencyType
    }

    public func getSymbol() -> String {
        return currencyType.symbol ?? currencyName
    }
    
    public var description: String {
        return currencyName
    }
}

extension CurrencyDTO: CurrencyRepresentable {
    public var currencyCode: String {
        return self.currencyType.rawValue
    }
}
