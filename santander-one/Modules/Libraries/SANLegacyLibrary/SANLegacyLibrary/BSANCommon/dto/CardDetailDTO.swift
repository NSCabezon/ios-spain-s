import Foundation
import CoreDomain

public struct CardDetailDTO: Codable {

    public var clientName: String?
    public var holder: String?
    public var beneficiary: String?
    public var expirationDate: Date?
    public var linkedAccountOldContract: ContractDTO?
    public var creditLimitAmount: AmountDTO?
    public var currentBalance: AmountDTO?
    public var availableAmount: AmountDTO?
    public var purchaseLimitAmount: AmountDTO?
    public var cardTypeDescription: String?
    public var linkedAccountDescription: String?
    public var offLineLimitAmount: AmountDTO?
    public var onLineLimitAmount: AmountDTO?
    public var statusType: String?
    public var currency: String?
    public var creditCardAccountNumber: String?
    public var insurance: String?
    public var interestRate: String?
    public var withholdings: AmountDTO?
    public var previousPeriodInterest: AmountDTO?
    public var minimumOutstandingDue: AmountDTO?
    public var currentMinimumDue: AmountDTO?
    public var totalMinimumRepaymentAmount: AmountDTO?
    public var lastStatementDate: Date?
    public var nextStatementDate: Date?
    public var actualPaymentDate: Date?

    public init() {
        
    }

    private enum CodingKeys: String, CodingKey {
        case holder
        case beneficiary
        case expirationDate
        case linkedAccountOldContract
        case creditLimitAmount
        case currentBalance
        case availableAmount
        case purchaseLimitAmount
        case cardTypeDescription
        case linkedAccountDescription
        case offLineLimitAmount
        case onLineLimitAmount
        case statusType
        case currency
        case creditCardAccountNumber
        case insurance
        case interestRate
        case withholdings
        case previousPeriodInterest
        case minimumOutstandingDue
        case currentMinimumDue
        case totalMinimumRepaymentAmount
        case lastStatementDate
        case nextStatementDate
        case actualPaymentDate
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(holder, forKey: .holder)
        try container.encode(beneficiary, forKey: .beneficiary)
        try container.encode(expirationDate, forKey: .expirationDate)
        try container.encode(linkedAccountOldContract, forKey: .linkedAccountOldContract)
        try container.encode(creditLimitAmount, forKey: .creditLimitAmount)
        try container.encode(currentBalance, forKey: .currentBalance)
        try container.encode(availableAmount, forKey: .availableAmount)
        try container.encode(purchaseLimitAmount, forKey: .purchaseLimitAmount)
        try container.encode(cardTypeDescription, forKey: .cardTypeDescription)
        try container.encode(linkedAccountDescription, forKey: .linkedAccountDescription)
        try container.encode(offLineLimitAmount, forKey: .offLineLimitAmount)
        try container.encode(onLineLimitAmount, forKey: .onLineLimitAmount)
        try container.encode(statusType, forKey: .statusType)
        try container.encode(currency, forKey: .currency)
        try container.encode(creditCardAccountNumber, forKey: .creditCardAccountNumber)
        try container.encode(insurance, forKey: .insurance)
        try container.encode(interestRate, forKey: .interestRate)
        try container.encode(withholdings, forKey: .withholdings)
        try container.encode(previousPeriodInterest, forKey: .previousPeriodInterest)
        try container.encode(minimumOutstandingDue, forKey: .minimumOutstandingDue)
        try container.encode(currentMinimumDue, forKey: .currentMinimumDue)
        try container.encode(totalMinimumRepaymentAmount, forKey: .totalMinimumRepaymentAmount)
        try container.encode(lastStatementDate, forKey: .lastStatementDate)
        try container.encode(nextStatementDate, forKey: .nextStatementDate)
        try container.encode(actualPaymentDate, forKey: .actualPaymentDate)
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        holder = try values.decode(String?.self, forKey: .holder)
        beneficiary = try values.decode(String?.self, forKey: .beneficiary)
        expirationDate = try values.decode(Date?.self, forKey: .expirationDate)
        linkedAccountOldContract = try values.decode(ContractDTO?.self, forKey: .linkedAccountOldContract)
        creditLimitAmount = try values.decode(AmountDTO?.self, forKey: .creditLimitAmount)
        currentBalance = try values.decode(AmountDTO?.self, forKey: .currentBalance)
        availableAmount = try values.decode(AmountDTO?.self, forKey: .availableAmount)
        purchaseLimitAmount = try values.decode(AmountDTO?.self, forKey: .purchaseLimitAmount)
        cardTypeDescription = try values.decode(String?.self, forKey: .cardTypeDescription)
        linkedAccountDescription = try values.decode(String?.self, forKey: .linkedAccountDescription)
        offLineLimitAmount = try values.decode(AmountDTO?.self, forKey: .offLineLimitAmount)
        onLineLimitAmount = try values.decode(AmountDTO?.self, forKey: .onLineLimitAmount)
        statusType = try values.decode(String?.self, forKey: .statusType)
        currency = try values.decode(String?.self, forKey: .currency)
        creditCardAccountNumber = try values.decode(String?.self, forKey: .creditCardAccountNumber)
        insurance = try values.decode(String?.self, forKey: .insurance)
        interestRate = try values.decode(String?.self, forKey: .interestRate)
        withholdings = try values.decode(AmountDTO?.self, forKey: .withholdings)
        previousPeriodInterest = try values.decode(AmountDTO?.self, forKey: .previousPeriodInterest)
        minimumOutstandingDue = try values.decode(AmountDTO?.self, forKey: .minimumOutstandingDue)
        currentMinimumDue = try values.decode(AmountDTO?.self, forKey: .currentMinimumDue)
        totalMinimumRepaymentAmount = try values.decode(AmountDTO?.self, forKey: .totalMinimumRepaymentAmount)
        lastStatementDate = try values.decode(Date?.self, forKey: .lastStatementDate)
        nextStatementDate = try values.decode(Date?.self, forKey: .nextStatementDate)
        actualPaymentDate = try values.decode(Date?.self, forKey: .actualPaymentDate)
    }
}

extension CardDetailDTO: CardDetailRepresentable {
    public var creditLimitAmountRepresentable: AmountRepresentable? {
        creditLimitAmount
    }
    public var withholdingsRepresentable: AmountRepresentable? {
        withholdings
    }
    
    public var previousPeriodInterestRepresentable: AmountRepresentable? {
        previousPeriodInterest
    }
    
    public var minimumOutstandingDueRepresentable: AmountRepresentable? {
        minimumOutstandingDue
    }
    
    public var currentMinimumDueRepresentable: AmountRepresentable? {
        currentMinimumDue
    }
    
    public var totalMinimumRepaymentAmountRepresentable: AmountRepresentable? {
        totalMinimumRepaymentAmount
    }
    
    public var linkedAccountShort: String {
        guard let linkedChargeAccount = linkedAccountDescription else { return "****" }
        return "*" + (linkedChargeAccount.substring(linkedChargeAccount.count - 4) ?? "*")
    }
    
    public var isCardBeneficiary: Bool {
        if let beneficiary = self.beneficiary, clientName?.trim() == beneficiary.trim() {
            return true
        }
        return false
    }
    
    public var cardBeneficiary: String? {
        cardTypeDescription
    }
    
    public var linkedAccount: String? {
        linkedAccountDescription
    }
    
    public var paymentModality: String? {
        nil
    }
    
    public var status: String? {
        statusType
    }
}
