import CoreDomain
import Foundation

public struct CheckExtractPdfRequestParams {
    public var token: String
    public var userDataDTO: UserDataDTO
    public var languageISO: String
    public var dialectISO: String
    public var company: String
    public var bankCode: String
    public var branchCode: String
    public var product: String
    public var contractName: String
    public var dateFilter: DateFilter?
    public var isPCAS: Bool
}
