public struct SepaCountryInfoEntity: DTOInstantiable {
    
    public let dto: CountryInfoDTO

    public init(_ dto: CountryInfoDTO) {
        self.dto = dto
    }
    
    public var code: String {
        return dto.code
    }
    public var name: String {
        return dto.name
    }
    public var currency: String? {
        return dto.currency
    }
    public var bbanLength: Int? {
        return dto.bbanLength
    }
    public var sepa: Bool {
        return dto.sepa
    }
    public var fxpay: Bool {
        return dto.fxpay ?? false
    }
    
    public func isIncludedFilteredBy(_ term: String) -> Bool {
        let term = term.folding(options: .diacriticInsensitive, locale: .current).lowercased()
        let name = self.name.folding(options: .diacriticInsensitive, locale: .current).lowercased()
        let code = self.code.folding(options: .diacriticInsensitive, locale: .current).lowercased()
        return name.contains(term) || code.contains(term)
    }
    
    public static func createSpain() -> SepaCountryInfoEntity {
        let dto = CountryInfoDTO(code: "ES", name: "España", currency: "EUR", bbanLength: 20, sepa: true, fxpay: true)
        return SepaCountryInfoEntity(dto)
    }
    
    public static func createPortugal() -> SepaCountryInfoEntity {
        let dto = CountryInfoDTO(code: "PT", name: "Portugal", currency: "EUR", bbanLength: 21, sepa: true, fxpay: true)
        return SepaCountryInfoEntity(dto)
    }
}

extension SepaCountryInfoEntity: CountryCurrencyItemConformable {}
