import CoreDomain

public final class OneInputAmountViewModel {
    public let status: OneStatus
    public let type: AmountType
    public let placeholder: String?
    public let amountRepresentable: AmountRepresentable?
    public let accessibilitySuffix: String?

    public init(status: OneStatus = .activated,
                type: AmountType = .unowned,
                placeholder: String? = nil,
                amountRepresentable: AmountRepresentable? = nil,
                accessibilitySuffix: String? = nil) {
        self.status = status
        self.type = type
        self.placeholder = placeholder
        self.amountRepresentable = amountRepresentable
        self.accessibilitySuffix = accessibilitySuffix
    }
    
    public var amount: String? {
        guard let value = amountRepresentable?.value, !value.isZero else { return nil }
        return NSDecimalNumber(decimal: value).stringValue
    }
    
    public enum AmountType {
        case text
        case icon
        case unowned
    }
}
