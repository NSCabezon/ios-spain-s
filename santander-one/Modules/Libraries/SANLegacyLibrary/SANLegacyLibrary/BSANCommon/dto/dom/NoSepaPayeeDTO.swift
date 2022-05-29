import CoreDomain

public struct MessageSwiftCenterNoSepaPayeeDTO: Codable {
    public var company: String?
    public var center: String?

    public init() {}
}

public struct NoSepaPayeeDTO: Codable {
    public var swiftCode: String?
    public var messageSwiftCenter: MessageSwiftCenterNoSepaPayeeDTO?
    public var paymentAccountDescription: String?
    public var name: String?
    public var town: String?
    public var address: String?
    public var countryName: String?
    public var countryCode: String?
    public var residentIndicator: String?
    public var bankAddress: String?
    public var bankTown: String?
    public var bankName: String?
    public var bankCountryCode: String?
    public var bankCountryName: String?
    public var residentDescription: String?
    
    //MARK - Init when parser Payee in "detalleEmitidaNoSepaLa" service
    public init(swiftCode: String?, messageSwiftCenter: MessageSwiftCenterNoSepaPayeeDTO?, paymentAccountDescription: String?, name: String?, town: String?, address: String?, residentIndicator: String?, bankName: String?, bankAddress: String?, bankTown: String?, bankCountryName: String?, residentDescription: String?) {
        self.swiftCode = swiftCode
        self.messageSwiftCenter = messageSwiftCenter
        self.paymentAccountDescription = paymentAccountDescription
        self.name = name
        self.town = town
        self.address = address
        self.residentIndicator = residentIndicator
        self.bankAddress = bankAddress
        self.bankTown = bankTown
        self.bankName = bankName
        self.bankCountryName = bankCountryName
        self.residentDescription = residentDescription
    }
    
    //MARK - Init when parser Payee in "detallePayeeNoSepaLa" service
    public init(swiftCode: String?, paymentAccountDescription: String?, name: String?, town: String?, address: String?, countryName: String?, countryCode: String?, bankName: String?, bankAddress: String?, bankTown: String?, bankCountryCode: String?, bankCountryName: String?) {
        self.swiftCode = swiftCode
        self.paymentAccountDescription = paymentAccountDescription
        self.name = name
        self.town = town
        self.address = address
        self.countryName = countryName
        self.countryCode = countryCode
        self.bankAddress = bankAddress
        self.bankTown = bankTown
        self.bankName = bankName
        self.bankCountryCode = bankCountryCode
        self.bankCountryName = bankCountryName
    }
}

extension NoSepaPayeeDTO: NoSepaPayeeRepresentable {}
