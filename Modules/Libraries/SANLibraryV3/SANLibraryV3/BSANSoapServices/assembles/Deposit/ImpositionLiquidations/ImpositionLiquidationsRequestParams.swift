import CoreDomain
import Foundation

public struct ImpositionLiquidationsRequestParams: FiltrableRequest {
    public var token: String
    public var userDataDTO: UserDataDTO
    public var terminalId: String
    public var version: String
    public var language: String
    public var subContractString: String
    public var currency: String
    public var bankCode: String
    public var branchCode: String
    public var product: String
    public var contractNumber: String
    public var dateFilter: DateFilter?
    public var pagination: PaginationDTO?
}
