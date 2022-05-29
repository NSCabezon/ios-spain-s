import Foundation
import CoreDomain

struct MockCardDetail: CardDetailRepresentable {
    var holder: String?
    var linkedAccountShort: String
    var isCardBeneficiary: Bool
    var beneficiary: String?
    var expirationDate: Date?
    var linkedAccount: String?
    var paymentModality: String?
    var status: String?
    var currency: String?
    var creditCardAccountNumber: String?
    var insurance: String?
    var interestRate: String?
    var withholdingsRepresentable: AmountRepresentable?
    var previousPeriodInterestRepresentable: AmountRepresentable?
    var minimumOutstandingDueRepresentable: AmountRepresentable?
    var currentMinimumDueRepresentable: AmountRepresentable?
    var totalMinimumRepaymentAmountRepresentable: AmountRepresentable?
    var lastStatementDate: Date?
    var nextStatementDate: Date?
    var actualPaymentDate: Date?
    
    init() {
        self.linkedAccountShort = ""
        self.isCardBeneficiary = false
    }
}
