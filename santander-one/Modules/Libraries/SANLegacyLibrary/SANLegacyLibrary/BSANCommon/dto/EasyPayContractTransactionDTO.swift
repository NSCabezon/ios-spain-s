import Foundation
import CoreDomain

public struct EasyPayContractTransactionDTO: Codable {
    public var operationDate: Date?
    public var liquidationDate: Date?
    public var amountDTO: AmountDTO?
    public var transactionDay: String?
    public var transactionTime: String?
    public var bankOperation: String?
    public var basicOperation: String?
    public var balanceCode: String?
    public var requestStatus: String?
    public var paymentMethodMode: String?
    public var paymentMethodCode: String?
    public var liquidationsType: String?
    public var compoundField: String?
    public var beneficiaryApeName: String?
    public var rateName: String?
    public var paymentMethodsPan: String?
    public var carcGroupDesc: String?
    public var transactionSequenceNumber: String?

    public init() {}
}

extension EasyPayContractTransactionDTO: EasyPayContractTransactionRepresentable {
    public var amount: AmountRepresentable? {
        amountDTO
    }
}
