import CoreFoundationLib
import SANLegacyLibrary

public struct MockCurrencyFormatterProvider {
    public init() {}
}

extension MockCurrencyFormatterProvider: CurrencyFormatterProvider {
    public var defaultCurrency: CurrencyType { .eur }
    
    public var decimalSeparator: Character { "," }
    
    public var millionsThreshold: Decimal { 1000000 }
    
    public func assembleCurrencyString(for value: String, with symbol: String, representation: AmountRepresentation) -> CurrencySymbolPosition {
        return .right
    }
}
