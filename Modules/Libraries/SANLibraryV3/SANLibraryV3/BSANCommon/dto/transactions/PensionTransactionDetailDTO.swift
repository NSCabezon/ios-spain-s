public struct PensionTransactionDetailDTO: Codable {
    public var feeAmount: AmountDTO?
    public var capital: AmountDTO?
    public var interestAmount: AmountDTO?
    public var pendingAmount: AmountDTO?

}
