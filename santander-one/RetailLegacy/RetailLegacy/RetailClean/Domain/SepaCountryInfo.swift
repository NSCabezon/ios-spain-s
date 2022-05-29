import CoreFoundationLib

struct SepaCountryInfo {
    let dto: CountryInfoDTO

    static func createSpain() -> SepaCountryInfo {
        let dto = CountryInfoDTO(code: "ES", name: "España", currency: "EUR", bbanLength: 20, sepa: true, fxpay: true, isAlphanumeric: false)
        return SepaCountryInfo(dto: dto)
    }
    
    static func create(_ entity: SepaCountryInfoEntity) -> SepaCountryInfo {
        return SepaCountryInfo(dto: entity.dto)
    }
    
    var entity: SepaCountryInfoEntity {
        return SepaCountryInfoEntity(dto)
    }
    
    var code: String {
        return dto.code
    }
    var name: String {
        return dto.name
    }
    var currency: String? {
        return dto.currency
    }
    var bbanLength: Int? {
        return dto.bbanLength
    }
    var sepa: Bool {
        return dto.sepa
    }
    var fxpay: Bool {
        return dto.fxpay ?? false
    }
}

extension SepaCountryInfo: FilterableSortableAndTitleDescriptionRepresentable {
    
    var representableTitle: String {
        return name
    }
    
    var representableDescription: String? {
        return nil
    }
    
    func isIncludedFilteredBy(_ term: String) -> Bool {
        let term = term.folding(options: .diacriticInsensitive, locale: .current).lowercased()
        let name = self.name.folding(options: .diacriticInsensitive, locale: .current).lowercased()
        let code = self.code.folding(options: .diacriticInsensitive, locale: .current).lowercased()
        return name.contains(term) || code.contains(term)
    }
    
    func sortedBy() -> String {
        return name
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(code)
    }
    
    static func == (lhs: SepaCountryInfo, rhs: SepaCountryInfo) -> Bool {
        return lhs.code == rhs.code
    }
}
