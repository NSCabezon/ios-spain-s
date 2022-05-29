import Foundation

public struct CardSuperSpeedDTO: Codable {
    public var PAN: String?
    public var cardType: String?
    public var expirationDate: String?
    
    public var visualCode: String?
    public var creditLimitAmount: AmountDTO?
    public var currentBalance: AmountDTO?
    public var availableAmount: AmountDTO?
    public var stampingName: String?
    
    public var indActive: String?
    public var indBlocking: String?
    
    public var mark: String?
    
    public var qualityParticipation: String?
    public var timeMark: String?
    public var dateAuthorizationDay: Date?
    public var temporaryLimitDailyCredit: AmountDTO?
    public var limitDailyCredit: AmountDTO?
    public var limitMaximumDailyCredit: AmountDTO?
    public var limitMaximumMonthlyCredit: AmountDTO?
    public var limitMonthlyCredit: AmountDTO?
    public var limitCreditCard: AmountDTO?
    public var temporaryLimitMonthlyCredit: AmountDTO?
    public var temporaryLimitCreditCard: AmountDTO?
    public var temporaryLimitDailyDebit: AmountDTO?
    public var temporaryLimitMonthlyDebit: AmountDTO?
    public var dailyDebitLimit: AmountDTO?
    public var maximumDailyDebitLimit: AmountDTO?
    public var maximumMonthlyDebitLimit: AmountDTO?
    public var limitMonthlyDebit: AmountDTO?
    public var dailyCashierLimit: AmountDTO?
    public var maximumDailyCashierLimit: AmountDTO?
    public var numberLimitOperationsDay: String?
    public var numberMaximumOperationsDay: String?
    public var numberLimitOperationsMonth: String?
    public var numberMaximumOperationsMonth: String?
    public var numberLimitOperationsDayCashier: String?
    public var numberMaximumOperationsDayCashier: String?
    public var temporaryLimitCreditStart: String?
    public var temporaryLimitCreditEnd: String?
    public var temporaryLimitCreditMonthStart: String?
    public var temporaryLimitCreditMonthEnd: String?
    public var temporaryLimitCreditDayStart: String?
    public var temporaryLimitCreditDayEnd: String?
    public var temporaryLimitDebitMonthStart: String?
    public var temporaryLimitDebitMonthEnd: String?
    public var temporaryLimitDebitDayStart: String?
    public var temporaryLimitDebitDayEnd: String?
    
    public init() {}
}
