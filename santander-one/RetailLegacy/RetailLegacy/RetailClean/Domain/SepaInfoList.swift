import CoreFoundationLib

struct SepaInfoList {
    let allCurrencies: [SepaCurrencyInfo]
    let allCountries: [SepaCountryInfo]
    
    init(dto: SepaInfoListDTO?) {
        allCurrencies = dto?.allCurrencies.map { SepaCurrencyInfo(dto: $0) } ?? []
        allCountries =  dto?.allCountries.map { SepaCountryInfo(dto: $0) } ?? []
    }
    
    init(allCurrencies: [SepaCurrencyInfo], allCountries: [SepaCountryInfo]) {
        self.allCurrencies = allCurrencies
        self.allCountries = allCountries
    }
    
    init(entity: SepaInfoListEntity) {
        self.allCurrencies = entity.allCurrencies.map { SepaCurrencyInfo(dto: $0.dto) }
        self.allCountries = entity.allCountries.map { SepaCountryInfo(dto: $0.dto) }
    }
}

extension SepaInfoList {
    
    func isCountryCodePresent(_ countryCode: String) -> Bool {
        return allCountries.map { $0.code }.contains(countryCode)
    }
    
    func countryFor(_ countryCode: String) -> String? {
        return allCountries.first(where: { $0.code == countryCode })?.name
    }
    
    func currencyFor(_ currencyCode: String) -> String? {
        return allCurrencies.first(where: { $0.code == currencyCode })?.name
    }
    
    func getSepaCountryInfo(_ countryCode: String? = "ES") -> SepaCountryInfo {
        return allCountries.first(where: { $0.code == countryCode }) ?? SepaCountryInfo.createSpain()
    }
    
    func getSepaCurrencyInfo(_ currencyCode: String? = "EUR") -> SepaCurrencyInfo {
        return allCurrencies.first(where: { $0.code == currencyCode }) ?? SepaCurrencyInfo.createEuro()
    }
    
    func getSepaInfoListEntity() -> SepaInfoListEntity {
        let sepaCurrencyInfoEntity = allCurrencies.map { SepaCurrencyInfoEntity($0.dto) }
        let sepaCountryInfoEntity = allCountries.map { SepaCountryInfoEntity($0.dto) }
        return SepaInfoListEntity(allCurrencies: sepaCurrencyInfoEntity, allCountries: sepaCountryInfoEntity)
    }
}
