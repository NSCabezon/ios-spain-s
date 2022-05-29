public struct SepaCurrencyInfoEntity: DTOInstantiable {
    
    public let dto: CurrencyInfoDTO
    
    public init(_ dto: CurrencyInfoDTO) {
        self.dto = dto
    }
    public static func createEuro() -> SepaCurrencyInfoEntity {
        let dto = CurrencyInfoDTO(name: "Euro", symbol: "€", code: "EUR")
        return SepaCurrencyInfoEntity(dto)
    }
    public var name: String {
        return dto.name
    }
    public var symbol: String? {
        return dto.symbol
    }
    public var code: String {
        return dto.code
    }  
    public var getSymbol: String {
        return symbol ?? code
    }        
    public func isIncludedFilteredBy(_ term: String) -> Bool {
        let term = term.folding(options: .diacriticInsensitive, locale: .current).lowercased()
        let name = self.name.folding(options: .diacriticInsensitive, locale: .current).lowercased()
        let code = self.code.folding(options: .diacriticInsensitive, locale: .current).lowercased()
        return name.contains(term) || code.contains(term)
    }
}

extension SepaCurrencyInfoEntity: Equatable {
    public static func == (lhs: SepaCurrencyInfoEntity, rhs: SepaCurrencyInfoEntity) -> Bool {
        return lhs.code == rhs.code
    }
}

extension SepaCurrencyInfoEntity: CountryCurrencyItemConformable {}
