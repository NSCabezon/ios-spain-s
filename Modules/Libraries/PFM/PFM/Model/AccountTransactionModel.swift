public struct AccountTransactionModel {
    public let transaction: TransactionModel
    public let type: String
    public let productSubtypeCode: String
    public let terminalCode: String
    public let number: String
    public let center: String
    public let company: String
    public let balance: Int64
    
    public init(transaction: TransactionModel, type: String?, productSubtypeCode: String?, terminalCode: String?, number: String?, center: String?, company: String?, balance: Int64?) {
        self.transaction = transaction
        self.type = type ?? ""
        self.productSubtypeCode = productSubtypeCode ?? ""
        self.terminalCode = terminalCode ?? ""
        self.number = number ?? ""
        self.center = center ?? ""
        self.company = company ?? ""
        self.balance = balance ?? 0
    }
}
