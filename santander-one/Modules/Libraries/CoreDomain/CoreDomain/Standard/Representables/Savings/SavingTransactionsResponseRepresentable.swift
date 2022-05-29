public protocol SavingTransactionsResponseRepresentable {
    var data: SavingTransactionDataRepresentable { get }
    var pagination: SavingPaginationRepresentable? { get }
}
