public struct PaymentBillTaxesDTO: Codable {
    public var takingsIssuing: TakingsIssuingDTO?
    public var billAmount: AmountDTO?
    public var issuingDescription: String?
    public var takingsDescription: String?
    public var bankChargesAmount: AmountDTO?
    public var taxAmount: AmountDTO?
    public var bankChargesIndicator: Bool?
    public var reference: String?
    public var referenceDescription: String?
    public var list: [PaymentBillTaxesItemDTO]?
    
    public init() {}
}
