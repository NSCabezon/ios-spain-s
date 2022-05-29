import Foundation

public struct GetStockQuotesRequestParams {
    public var token: String
    public var userDataDTO: UserDataDTO
    public var terminalId: String
    public var version: String
    public var language: String
    public var searchString: String
    public var pagination : PaginationDTO?
}
