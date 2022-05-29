import CoreDomain
import Foundation

public struct PensionTransactionsRequestParams: FiltrableRequest {
	public var token: String
	public var userDataDTO: UserDataDTO
	public var terminalId: String
	public var version: String
	public var language: String
	
	public var bankCode: String
	public var branchCode: String
	public var product: String
	public var contractNumber: String
	public var pagination: PaginationDTO?
	public var currencyType: CurrencyType?
	public var dateFilter: DateFilter?
}
