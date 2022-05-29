import Foundation
import CoreDomain
import UnitTestCommons

struct MockCardDetail: CardDetailRepresentable {
    var clientName: String?
    @Stub var holder: String?
    @Stub var linkedAccountShort: String
    @Stub var isCardBeneficiary: Bool
    @Stub var beneficiary: String?
    @Stub var expirationDate: Date?
    @Stub var linkedAccount: String?
    @Stub var paymentModality: String?
    @Stub var status: String?
    @Stub var currency: String?
    @Stub var creditCardAccountNumber: String?
    @Stub var insurance: String?
    @Stub var interestRate: String?
    @Stub var creditLimitAmountRepresentable: AmountRepresentable?
    @Stub var withholdingsRepresentable: AmountRepresentable?
    @Stub var previousPeriodInterestRepresentable: AmountRepresentable?
    @Stub var minimumOutstandingDueRepresentable: AmountRepresentable?
    @Stub var currentMinimumDueRepresentable: AmountRepresentable?
    @Stub var totalMinimumRepaymentAmountRepresentable: AmountRepresentable?
    @Stub var lastStatementDate: Date?
    @Stub var nextStatementDate: Date?
    @Stub var actualPaymentDate: Date?
}
