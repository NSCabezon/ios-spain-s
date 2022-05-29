import CoreFoundationLib

struct SepaCurrencyInfo {
     //TODO: Se añade Euro a fuego. Se va a volver a quitar. (NO SEPA)
    static func createEuro() -> SepaCurrencyInfo {
        let dto = CurrencyInfoDTO(name: "Euro", symbol: "€", code: "EUR")
        return SepaCurrencyInfo(dto: dto)
    }
    
    static func create(_ entity: SepaCurrencyInfoEntity) -> SepaCurrencyInfo {
        return SepaCurrencyInfo(dto: entity.dto)
    }
    
    var entity: SepaCurrencyInfoEntity {
        return SepaCurrencyInfoEntity(dto)
    }
    
    let dto: CurrencyInfoDTO
    var name: String {
        return dto.name
    }
    var symbol: String? {
        return dto.symbol
    }
    var code: String {
        return dto.code
    }
    var currency: Currency {
        return Currency.create(withName: code)
    }    
    var getSymbol: String {
        return symbol ?? code
    }
}

extension SepaCurrencyInfo: FilterableSortableAndTitleDescriptionRepresentable {
    
    var representableTitle: String {
        return name
    }
    
    var representableDescription: String? {
        return code
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
    
    static func == (lhs: SepaCurrencyInfo, rhs: SepaCurrencyInfo) -> Bool {
        return lhs.code == rhs.code
    }
}
