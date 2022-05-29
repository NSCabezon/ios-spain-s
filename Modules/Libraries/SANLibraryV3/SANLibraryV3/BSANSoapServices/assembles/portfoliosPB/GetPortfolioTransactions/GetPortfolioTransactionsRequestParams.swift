import CoreDomain
import Foundation

public struct GetPortfolioTransactionsRequestParams: FiltrableRequest {
    public var token: String
    public var userDataDTO: UserDataDTO
    public var terminalId: String
    public var version: String
    public var languageISO: String
    public var dialectISO: String
    public var portfolioId: String
    public var portfolioValueName : String
    public var portfolioActiveType : String
    public var dateFilter: DateFilter?
    public var pagination: PaginationDTO?
}
