import CoreDomain

public struct SepaInfoListDTO: Codable {
    public let allCurrencies: [CurrencyInfoDTO]
    public let allCountries: [CountryInfoDTO]
}

extension SepaInfoListDTO: SepaInfoListRepresentable {
    public var allCurrenciesRepresentable: [CurrencyInfoRepresentable] {
        return allCurrencies
    }
    
    public var allCountriesRepresentable: [CountryInfoRepresentable] {
        return allCountries
    }
}
