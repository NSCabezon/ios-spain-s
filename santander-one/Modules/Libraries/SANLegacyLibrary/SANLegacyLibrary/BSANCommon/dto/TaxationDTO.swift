import Foundation

public struct TaxationDTO: Codable {
    public var interestsLastGrossLiquidation: Decimal?
    public var interestsLastSettlementRetentionInt: Decimal?
    public var interestsLastSettlementRetentionPorc: Decimal?
    public var interestLastLiquidationInterest: Decimal?
    public var annualGrossInterest: Decimal?
    public var annualInterestRetention: Decimal?
    public var annualInterestNet: Decimal?
    public var annualInterestIncomeNext: Decimal?
    public var annualInterestTotal: Decimal?
    public var cashbackUltimateLiquidationGross: Decimal?
    public var cashbackLastSettlementRetentionInt: Decimal?
    public var cashbackLastSettlementRetentionPorc: Decimal?
    public var cashbackAnnualGross: Decimal?
    public var cashbackAnnualRetention: Decimal?
    public var cashbackAnnualNet: Decimal?
    public var actionsLastValidationValueMarket: Decimal?
    public var actionsLiquidationIncome: Decimal?
    public var actionsLiquitationRetention: Decimal?
    public var annualStockMarket: Decimal?
    public var annualIncomeActions: Decimal?
    public var annualActions: Decimal?

    public init () {}
}
