import Foundation
import CoreDomain

public struct MockCardDetail: CardDetailRepresentable {
    public var clientName: String?
    @Stub public var holder: String?
    @Stub public var linkedAccountShort: String
    @Stub public var isCardBeneficiary: Bool
    @Stub public var beneficiary: String?
    @Stub public var expirationDate: Date?
    @Stub public var linkedAccount: String?
    @Stub public var paymentModality: String?
    @Stub public var status: String?
    @Stub public var currency: String?
    @Stub public var creditCardAccountNumber: String?
    @Stub public var insurance: String?
    @Stub public var interestRate: String?
    @Stub public var creditLimitAmountRepresentable: AmountRepresentable?
    @Stub public var withholdingsRepresentable: AmountRepresentable?
    @Stub public var previousPeriodInterestRepresentable: AmountRepresentable?
    @Stub public var minimumOutstandingDueRepresentable: AmountRepresentable?
    @Stub public var currentMinimumDueRepresentable: AmountRepresentable?
    @Stub public var totalMinimumRepaymentAmountRepresentable: AmountRepresentable?
    @Stub public var lastStatementDate: Date?
    @Stub public var nextStatementDate: Date?
    @Stub public var actualPaymentDate: Date?
    
    public init() {}
}
