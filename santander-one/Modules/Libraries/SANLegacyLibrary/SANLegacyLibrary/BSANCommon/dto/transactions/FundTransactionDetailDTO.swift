import CoreDomain

public struct FundTransactionDetailDTO: Codable {
    public var operationTypeDesc: String?
    public var situationDesc: String?
    public var descIBANChargeIncome: String?
    public var operationExpensesAmount: AmountDTO?
    public var impOperation: AmountDTO?
    public var IBANChargeIncome: IBANDTO?
    
    public init() {}
}

extension FundTransactionDetailDTO: FundMovementDetailRepresentable {
}
