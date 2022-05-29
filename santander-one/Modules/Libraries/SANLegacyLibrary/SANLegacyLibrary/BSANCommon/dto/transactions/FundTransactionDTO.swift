import Foundation
import CoreDomain

public struct FundTransactionDTO: BaseTransactionDTO {
	public var operationDate: Date?
	public var amount: AmountDTO?
	public var description: String?

	public var bankOperationCode: String?
	public var applyDate: Date?
	public var settlementAmount: AmountDTO?
	public var sharesCount: Decimal?
	public var valueDate: Date?
	public var transactionNumber: String?
	public var productSubtypeCode: String?

    public init() {}

    public func getFundTransactionKey() -> String?{
        
        if self.applyDate == nil && self.transactionNumber == nil{
            return nil
        }
        
        let dateString = (self.applyDate != nil) ? "\(self.applyDate!)" : ""
        return "\(dateString)\(self.transactionNumber ?? "")"
    }
}

extension FundTransactionDTO: FundMovementRepresentable {

    public var dateRepresentable: Date? {
        return applyDate
    }

    public var submittedDateRepresentable: Date? {
        return operationDate
    }

    public var nameRepresentable: String?  {
        return description
    }

    public var amountRepresentable: AmountRepresentable?  {
        return amount
    }

    public var unitsRepresentable: String? {
        guard let sharesCount = sharesCount else {
            return nil
        }
        return AmountFormats.getSharesFormattedForWS(sharesNumber: sharesCount)
    }
}
