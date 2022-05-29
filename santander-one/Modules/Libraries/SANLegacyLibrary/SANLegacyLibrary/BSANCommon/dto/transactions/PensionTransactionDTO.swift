import Foundation

public struct PensionTransactionDTO: BaseTransactionDTO {
	public var operationDate: Date?
	public var amount: AmountDTO?
	public var description: String?
	
	public var sharesCount: Decimal?
	public var transactionNumber: String?
    
    public init() {}
}
