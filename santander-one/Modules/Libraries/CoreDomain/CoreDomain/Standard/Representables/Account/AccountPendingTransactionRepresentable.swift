public protocol AccountPendingTransactionRepresentable {
    var amountRepresentable: AmountRepresentable? { get }
    var operationDate: Date? { get }
    var valueDate: Date? { get }
    var entryStatus: TransactionStatusRepresentableType? { get }
    var transactionID: String? { get }
    var description: String? { get }
}

public extension AccountPendingTransactionRepresentable {
    func equalsTo(other: AccountPendingTransactionRepresentable) -> Bool {
        return self.transactionID == other.transactionID
    }
}

public extension AccountPendingTransactionRepresentable {
    var isNegativeAmount: Bool {
        return (self.amountRepresentable?.value ?? 0.0).isSignMinus
    }
}
