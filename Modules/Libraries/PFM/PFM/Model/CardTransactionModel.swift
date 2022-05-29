public struct CardTransactionModel {
    public var transaction: TransactionModel
    public var balanceCode: String
    
    public init(transaction: TransactionModel, balanceCode: String?) {
        self.transaction = transaction
        self.balanceCode = balanceCode ?? ""
    }
}
