import CoreDomain
import Foundation

public struct GetFundTransactionsRequestParams: FiltrableRequest {
	public var token: String
	public var userDataDTO: UserDataDTO
	public var terminalId: String
	public var version: String
	public var language: String
	
	public var bankCode: String
	public var branchCode: String
	public var product: String
	public var contractNumber: String
	public var dateFilter: DateFilter?
	public var currencyType: CurrencyType?
	public var pagination: PaginationDTO?
}
