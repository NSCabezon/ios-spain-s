public protocol TransactionBalanceRepresentable {
    var type: String { get }
    var amount: AmountRepresentable { get }
    var creditDebitIndicator: String { get }
}
