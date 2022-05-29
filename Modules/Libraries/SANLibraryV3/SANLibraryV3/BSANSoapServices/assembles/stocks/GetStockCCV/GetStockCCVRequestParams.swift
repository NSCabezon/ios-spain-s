import Foundation

public struct GetStockCCVRequestParams {
    public var token: String
    public var userDataDTO: UserDataDTO
    public var terminalId: String
    public var version: String
    public var language: String
    public var contract: ContractDTO?
    public var pagination : PaginationDTO?
}
