import CoreDomain
import Foundation

public struct GetStockOrderRequestParams: FiltrableRequest {
    public var token: String
    public var userDataDTO: UserDataDTO
    public var terminalId: String
    public var version: String
    public var language: String
    public var stockContract: ContractDTO?
    public var pagination : PaginationDTO?
    public var dateFilter : DateFilter?
}
