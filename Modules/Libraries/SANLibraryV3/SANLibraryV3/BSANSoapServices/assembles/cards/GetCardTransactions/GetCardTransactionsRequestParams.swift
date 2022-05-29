import CoreDomain
import Foundation

public struct GetCardTransactionsRequestParams: FiltrableRequest {
    public var token: String
    public var userDataDTO: UserDataDTO
    public var bankCode: String
    public var branchCode: String
    public var product: String
    public var contractNumber: String
    public var cardPAN: String
    public var version: String
    public var language: String
    public var terminalId: String
    public var pagination: PaginationDTO?
    public var dateFilter: DateFilter?
}
