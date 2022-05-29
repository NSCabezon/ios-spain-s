public protocol CountryCurrencyItemConformable {
    var name: String { get }
    var code: String { get }
}

public struct SepaInfoListEntity {
    
    public let allCurrencies: [SepaCurrencyInfoEntity]
    public let allCountries: [SepaCountryInfoEntity]
    
    public init(dto: SepaInfoListDTO?) {
        self.allCurrencies = dto?.allCurrencies.map { SepaCurrencyInfoEntity($0) } ?? []
        self.allCountries = dto?.allCountries.map { SepaCountryInfoEntity($0) } ?? []
    }
    
    public init(allCurrencies: [SepaCurrencyInfoEntity], allCountries: [SepaCountryInfoEntity]) {
        self.allCurrencies = allCurrencies
        self.allCountries = allCountries
    }
}

extension SepaInfoListEntity {
    
    public func countryFor(_ countryCode: String) -> String? {
        return self.allCountries.first(where: { $0.code == countryCode })?.name
    }
    
    public func currencyFor(_ currencyCode: String) -> String? {
        return self.allCurrencies.first(where: { $0.code == currencyCode })?.name
    }
    
    public func currencySymbolFor(_ currencyCode: String) -> String? {
        return self.allCurrencies.first(where: { $0.code == currencyCode })?.symbol
    }
    
    public func currencyNameFor(_ currencySymbol: String) -> String? {
        return self.allCurrencies.first(where: { $0.symbol == currencySymbol })?.name
    }
}
