public protocol SavingTransactionBalanceRepresentable {
    var type: String { get }
    var amount: SavingAmountRepresentable { get }
    var creditDebitIndicator: String { get }
}
