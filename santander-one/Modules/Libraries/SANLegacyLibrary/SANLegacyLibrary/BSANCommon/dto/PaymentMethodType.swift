public enum PaymentMethodType: String, Codable {
    case monthlyPayment = "PM"
    case fixedFee = "CF"
    case minimalPayment = "MI"
    case deferredPayment = "PA"
    case immediatePayment = "PI"
    
    public init?(rawValue: String) {
        switch rawValue {
        case "01", "PM":
            self = PaymentMethodType.monthlyPayment
        case "02", "CF":
            self = PaymentMethodType.fixedFee
        case "03", "MI":
            self = PaymentMethodType.minimalPayment
        case "04", "PA":
            self = PaymentMethodType.deferredPayment
        case "05", "PI":
            self = PaymentMethodType.immediatePayment
        default:
            return nil
        }
    }
}
