public protocol SavingTransactionDataRepresentable {
    var transactions: [SavingTransactionRepresentable] { get }
    var accounts: [SavingAccountRepresentable]? { get }
}
