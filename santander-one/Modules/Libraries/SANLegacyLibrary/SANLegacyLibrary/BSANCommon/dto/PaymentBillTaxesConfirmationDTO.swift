public struct PaymentBillTaxesConfirmationDTO: Codable {
    public var posted: Bool?
    public var certiList: [String]?
    public var bankChargesAmount: AmountDTO?
    public var taxAmount: AmountDTO?
    
    public init() {}
}
