import Foundation

public struct NoSepaTransferEmittedDetailDTO: Codable {
    public var origin: IBANDTO?
    public var transferAmount: AmountDTO?
    public var emisionDate: Date?
    public var valueDate: Date?
    public var originName: String?
    public var spentIndicator: String?
    public var transferType: String?
    public var countryCode: String?
    public var concept1: String?
    public var spentDescIndicator: String?
    public var descTransferType: String?
    public var countryName: String?
    public var payee: NoSepaPayeeDTO?
    public var entityAuthPayment: EntityAuthPaymentDTO?
    public var expensesIndicator: String?

    public init() {}
}
