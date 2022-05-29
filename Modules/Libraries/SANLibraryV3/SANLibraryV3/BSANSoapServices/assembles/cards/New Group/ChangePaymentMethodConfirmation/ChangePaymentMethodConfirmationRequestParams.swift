public struct ChangePaymentMethodConfirmationRequestParams {
    public let token: String
    public let userDataDTO: UserDataDTO
    public let languageISO: String
    public let dialectISO: String
    public let linkedCompany: String
    public let newPaymentMethodDTO: PaymentMethodDTO
    
    public let referenceStandard: ReferenceStandardDTO
    public let hiddenReferenceStandard: ReferenceStandardDTO
    
    public let selectedAmount: AmountDTO
    
    public let bankCode: String
    public let branchCode: String
    public let product: String
    public let contractNumber: String
    
    public let marketCode: String
    public let currentPaymentMethod: PaymentMethodType?
    public let currentPaymentMethodMode: String
    public let currentSettlementType: String
    public let hiddenMarketCode: String
    public let hiddenPaymentMethodMode: String
    
}
