import Foundation

public struct AccountDetailDTO: Codable {
    public var lastUpdate: Date?
    public var currentValueDate: Date?
    public var bdpEnrollmentDate: Date?
    public var notebookIndicator: Bool?
    public var counterfoilBookIndicator: Bool?
    public var contractsPercentage: String?
    public var productName: String?
    public var holder: String?
    public var mainBalance: AmountDTO?
    public var description: String?
    public var accountId: String?
    public var bicCode: String?
    public var mainItem: Bool?
    public var iban: IBANDTO?
    public var balance: AmountDTO?
    public var realAmount: AmountDTO?
    public var overdraftAmount: AmountDTO?
    public var earningsAmount: AmountDTO?
    public var availableAmount: AmountDTO?
    public var creditAmount: AmountDTO?
    public var pendingConsolidationAmount: AmountDTO?
    public var withholdingAmount: AmountDTO?
    public var vacAmount: AmountDTO?
    public var contingencyAmount: AmountDTO?
    public var upperLimitAmount: AmountDTO?
    public var sectionMaxAmount: AmountDTO?
    public var estimatedAssignmentsVolume: AmountDTO?
    public var authorizedBalance: AmountDTO?
    public var customerId: String?
    public var lastTransactionDate: String?
    public var transactionsListLink: String?
    public var costCenter: String?
    public var interestRate: String?
    public init() {}
}
