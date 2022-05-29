
public struct BuyFeesParameters {
    
    public var numFees: Int
    public var balanceCode: String
    public var transactionDay: String
    
    public init(numFees: Int, balanceCode: String, transactionDay: String) {
        self.numFees = numFees
        self.balanceCode = balanceCode
        self.transactionDay = transactionDay
    }
}
