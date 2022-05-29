public struct PreliqDataDTO: Codable {
    public var liqConcept: String?
    public var chargeTypeInd: String?
    public var bankCharge: AmountDTO?
    public var standardAmount: AmountDTO?
    public var operationAmount: AmountDTO?
    public var notionalAmount: AmountDTO?
    public var commercialChannel: String?
    public var prepaidCurrentBalance: AmountDTO?
    public var totalOperationAmount: AmountDTO?
    public var receivableAmount: AmountDTO?
    public var referenceStandard: ReferenceStandardDTO?
    
    public init() {}
}
