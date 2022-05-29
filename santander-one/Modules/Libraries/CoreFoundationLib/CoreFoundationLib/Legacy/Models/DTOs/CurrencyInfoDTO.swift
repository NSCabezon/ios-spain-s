import CoreDomain

public struct CurrencyInfoDTO: Codable {
    public let name: String
    public let symbol: String?
    public let code: String
    
    public init(name: String, symbol: String?, code: String) {
        self.name = name
        self.symbol = symbol
        self.code = code
    }
}

extension CurrencyInfoDTO: CurrencyInfoRepresentable {}
