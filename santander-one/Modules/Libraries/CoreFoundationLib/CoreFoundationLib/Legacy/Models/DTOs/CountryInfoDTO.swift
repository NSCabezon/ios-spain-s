import CoreDomain

public struct CountryInfoDTO: Codable {
    public let code: String
    public let name: String
    public let currency: String?
    public let bbanLength: Int?
    public let sepa: Bool
    public let fxpay: Bool?
    public let isAlphanumeric: Bool?

    public init(code: String,
                name: String,
                currency: String?,
                bbanLength: Int?,
                sepa: Bool,
                fxpay: Bool?,
                isAlphanumeric: Bool? = nil) {
        self.code = code
        self.name = name
        self.currency = currency
        self.bbanLength = bbanLength
        self.sepa = sepa
        self.fxpay = fxpay
        self.isAlphanumeric = isAlphanumeric
    }
}

extension CountryInfoDTO: CountryInfoRepresentable {}
