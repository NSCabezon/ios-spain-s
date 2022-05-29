public struct DirectMoneyValidatedDTO: Codable {
    public var cardNumber: String?
    public var cardDescription: String?
    public var cardTypeDescription: String?
    public var minAmountDescription: String?
    public var cardContractStatusDesc: String?
    public var linkedAccountBank: String?
    public var linkedAccountBranch: String?
    public var linkedAccountCheckDigits: String?
    public var linkedAccountNumber: String?
    public var holder: String?
    public var availableAmount: AmountDTO?
    public var signature: SignatureDTO?

    public init() {}
}
