import CoreDomain
import Foundation

public enum BillListStatus: CustomStringConvertible {
    
    case all
    case canceled
    case applied
    case returned
    case pendingToApply
    case pendingOfDate
    case pendingToResolve
    
    public var description: String {
        switch self {
        case .all: return "999"
        case .canceled: return "ANU"
        case .applied: return "APL"
        case .returned: return "DEV"
        case .pendingToApply: return "PAP"
        case .pendingOfDate: return "PTF"
        case .pendingToResolve: return "PTR"
        }
    }
}

public struct BillListRequestParams {
    public let token: String
    public let userDataDTO: UserDataDTO
    public let language: String
    public let dialect: String
    public let accountDTO: AccountDTO
    public let paginationDTO: PaginationDTO?
    public let fromDate: DateModel
    public let toDate: DateModel
    public let status: BillListStatus
    
    public init(
        token: String,
        userDataDTO: UserDataDTO,
        language: String,
        dialect: String,
        accountDTO: AccountDTO,
        paginationDTO: PaginationDTO?,
        fromDate: DateModel,
        toDate: DateModel,
        status: BillListStatus
    ) {
        self.token = token
        self.userDataDTO = userDataDTO
        self.language = language
        self.dialect = dialect
        self.accountDTO = accountDTO
        self.paginationDTO = paginationDTO
        self.fromDate = fromDate
        self.toDate = toDate
        self.status = status
    }
}
