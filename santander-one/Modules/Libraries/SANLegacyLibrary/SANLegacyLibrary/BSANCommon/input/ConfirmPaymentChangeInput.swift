public struct ChangePaymentMethodConfirmationInput {
    
    public let referenceStandard: ReferenceStandardDTO
    public let hiddenReferenceStandard: ReferenceStandardDTO
    
    public let selectedAmount: AmountDTO
    
    public let currentPaymentMethod: PaymentMethodType?
    public let currentPaymentMethodMode: String
    public let currentSettlementType: String
    public let marketCode: String?
    
    public let hiddenMarketCode: String?
    public let hiddenPaymentMethodMode: String

    public let selectedPaymentMethod: PaymentMethodDTO
    
    public init(referenceStandard: ReferenceStandardDTO, hiddenReferenceStandard: ReferenceStandardDTO, selectedAmount: AmountDTO, currentPaymentMethod: PaymentMethodType?, currentPaymentMethodMode: String, currentSettlementType: String, marketCode: String?, hiddenMarketCode: String?, hiddenPaymentMethodMode: String, selectedPaymentMethod: PaymentMethodDTO) {
        self.referenceStandard = referenceStandard
        self.hiddenReferenceStandard = hiddenReferenceStandard
        self.selectedAmount = selectedAmount
        self.currentPaymentMethod = currentPaymentMethod
        self.currentPaymentMethodMode = currentPaymentMethodMode
        self.currentSettlementType = currentSettlementType
        self.marketCode = marketCode
        self.hiddenMarketCode = hiddenMarketCode
        self.hiddenPaymentMethodMode = hiddenPaymentMethodMode
        self.selectedPaymentMethod = selectedPaymentMethod
    }
}
