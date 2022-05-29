import Foundation

public struct AmortizationDTO: Codable {
    public var nextAmortizationDate: Date?
    public var interestAmount: AmountDTO?
    public var totalFeeAmount: AmountDTO?
    public var amortizedAmount: AmountDTO?
    public var pendingAmount: AmountDTO?

    public init() {}
}
