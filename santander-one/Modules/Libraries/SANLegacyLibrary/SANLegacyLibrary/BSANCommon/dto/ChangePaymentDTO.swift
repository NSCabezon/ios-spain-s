public struct ChangePaymentDTO: Codable {
    public var paymentMethodList: [PaymentMethodDTO]?
    public var marketCode: String?
    
    public var currentSettlementType: String?
    public var currentPaymentMethod: PaymentMethodType?
    public var currentPaymentMethodMode: String?
    public var referenceStandard: ReferenceStandardDTO?
    
    public var currentPaymentMethodTranslated: String?
    public var currentPaymentMethodDescription: String?
    
    public var hiddenMarketCode: String?
    public var hiddenPaymentMethodMode: String?
    public var hiddenReferenceStandard: ReferenceStandardDTO?

    
    public init(paymentMethodList: [PaymentMethodDTO]? = nil, marketCode: String? = nil, currentSettlementType: String? = nil, currentPaymentMethod: PaymentMethodType? = nil, currentPaymentMethodMode: String? = nil, referenceStandard: ReferenceStandardDTO? = nil, currentPaymentMethodTranslated: String? = nil, currentPaymentMethodDescription: String? = nil, hiddenMarketCode: String? = nil, hiddenPaymentMethodMode: String? = nil, hiddenReferenceStandard: ReferenceStandardDTO? = nil) {
        self.paymentMethodList = paymentMethodList
        self.marketCode = marketCode
        self.currentSettlementType = currentSettlementType
        self.currentPaymentMethod = currentPaymentMethod
        self.currentPaymentMethodMode = currentPaymentMethodMode
        self.referenceStandard = referenceStandard
        self.currentPaymentMethodTranslated = currentPaymentMethodTranslated
        self.currentPaymentMethodDescription = currentPaymentMethodDescription
        self.hiddenMarketCode = hiddenMarketCode
        self.hiddenPaymentMethodMode = hiddenPaymentMethodMode
        self.hiddenReferenceStandard = hiddenReferenceStandard
    }
}
