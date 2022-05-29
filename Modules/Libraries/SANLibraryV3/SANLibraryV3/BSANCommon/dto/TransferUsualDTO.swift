import Foundation

public struct TransferUsualDTO: Codable {
    public var issueDate: Date?
    public var transferAmount: AmountDTO?
    public var bankChargeAmount: AmountDTO?
    public var expensesAmount: AmountDTO?
    public var netAmount: AmountDTO?
    public var destinationAccountDescription: String?
    public var originAccountDescription: String?
    public var payerName: String?
    public var beneficiaryName: String?
    public var signature: SignatureDTO?
}
