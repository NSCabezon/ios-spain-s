import SANLegacyLibrary

struct Currency {
    private(set) var currencyDTO: CurrencyDTO
    
    static func create(withName currencyName: String) -> Currency {
        return Currency(dto: CurrencyDTO.create(currencyName))
    }
    
    static func create(withType currencyType: CurrencyType) -> Currency {
        return Currency(dto: CurrencyDTO.create(currencyType))
    }
    
    static func create(withDTO dto: CurrencyDTO) -> Currency {
        return Currency(dto: dto)
    }
    
    static func createEur() -> Currency {
        return Currency(dto: CurrencyDTO.create(.eur))
    }
    
    private init(dto: CurrencyDTO) {
        self.currencyDTO = dto
    }
    
    var currencyName: String {
        return currencyDTO.currencyName
    }
    
    public func getSymbol() -> String {
        return currencyDTO.getSymbol()
    }
    
    var symbol: String? {
        return currencyDTO.currencyType.symbol
    }
}
