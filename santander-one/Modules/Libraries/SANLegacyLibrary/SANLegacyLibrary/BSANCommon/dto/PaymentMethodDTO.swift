import Foundation

public struct PaymentMethodDTO: Codable {
    public var idRangeFP: String?
    public var liquidationType: String?
    public var paymentMethod: PaymentMethodType?
    public var paymentMethodDesc: String?
    public var thresholdDesc: Decimal?
    
    public var feeAmount: AmountDTO?
    public var incModeAmount: AmountDTO?
    public var maxModeAmount: AmountDTO?
    public var minAmortAmount: AmountDTO?
    public var minModeAmount: AmountDTO?
    
    public init(idRangeFP: String? = nil, liquidationType: String? = nil, paymentMethod: PaymentMethodType? = nil, paymentMethodDesc: String? = nil, thresholdDesc: Decimal? = nil, feeAmount: AmountDTO? = nil, incModeAmount: AmountDTO? = nil, maxModeAmount: AmountDTO? = nil, minAmortAmount: AmountDTO? = nil, minModeAmount: AmountDTO? = nil) {
        self.idRangeFP = idRangeFP
        self.liquidationType = liquidationType
        self.paymentMethod = paymentMethod
        self.paymentMethodDesc = paymentMethodDesc
        self.thresholdDesc = thresholdDesc
        self.feeAmount = feeAmount
        self.incModeAmount = incModeAmount
        self.maxModeAmount = maxModeAmount
        self.minAmortAmount = minAmortAmount
        self.minModeAmount = minModeAmount
    }
}
