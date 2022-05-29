public struct CardSubscriptionHistoricalDTO: Codable {
    public let entityCode: String?
    public let centerCode: String?
    public let numberProduct: String?
    public let accountNumber: String?
    public let currency: String?
    public let creditExtractNum: String?
    public let creditMovementNum: String?
    public let debitMovementNum: String?
    public let innorcor: String?
    public let tifactur: String?
    public let operationSign: String?
    public let date: String?
    public let cdgcomer: String?
    public let providerName: String?
    public let value: String?
    public let cdconeco1: String?
    public let tiimp1: String?
    public let imbueco1: String?
    public let descconeco1: String?
    public let cdconeco2: String?
    public let tiimp2: String?
    public let imbueco2: String?
    public let descconeco2: String?
    public let fractionableIndicator: String?
    
    public var amount: AmountDTO? {
        guard let value = value,
              let doubleValue = Double(value),
              let currency = currency else { return nil }
        return AmountDTO(value: Decimal(doubleValue),
                         currency: CurrencyDTO.create(currency))
    }
    
    public var isFractionable: Bool {
        return fractionableIndicator?.trim().uppercased() == "S"
    }

    enum CodingKeys: String, CodingKey {
        case entityCode = "cdgenti"
        case centerCode = "centalta"
        case numberProduct = "prod"
        case accountNumber = "numcta"
        case currency = "clamon"
        case creditExtractNum = "nuextcta"
        case creditMovementNum = "numvtoex"
        case debitMovementNum = "numovdeb"
        case innorcor = "innorcor"
        case tifactur = "tifactur"
        case operationSign = "signo"
        case date = "fecfac"
        case cdgcomer = "cdgcomer"
        case providerName = "nomcomre"
        case value = "impliqope"
        case cdconeco1 = "cdconeco1"
        case tiimp1 = "tiimp1"
        case imbueco1 = "imbueco1"
        case descconeco1 = "descconeco1"
        case cdconeco2 = "cdconeco2"
        case tiimp2 = "tiimp2"
        case imbueco2 = "imbueco2"
        case descconeco2 = "descconeco2"
        case fractionableIndicator = "incompcu"
    }
}
