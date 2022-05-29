public protocol CardDetailRepresentable {
    var holder: String? { get }
    var clientName: String? { get set }
    var linkedAccountShort: String { get }
    var isCardBeneficiary: Bool { get }
    var beneficiary: String? { get }
    var expirationDate: Date? { get }
    var linkedAccount: String? { get }
    var paymentModality: String? { get }
    var status: String? { get }
    var currency: String? { get }
    var creditCardAccountNumber: String? { get }
    var insurance: String? { get }
    var interestRate: String? { get }
    var withholdingsRepresentable: AmountRepresentable? { get }
    var previousPeriodInterestRepresentable: AmountRepresentable? { get }
    var minimumOutstandingDueRepresentable: AmountRepresentable? { get }
    var currentMinimumDueRepresentable: AmountRepresentable? { get }
    var totalMinimumRepaymentAmountRepresentable: AmountRepresentable? { get }
    var creditLimitAmountRepresentable: AmountRepresentable? { get }
    var lastStatementDate: Date? { get }
    var nextStatementDate: Date? { get }
    var actualPaymentDate: Date? { get }
}
