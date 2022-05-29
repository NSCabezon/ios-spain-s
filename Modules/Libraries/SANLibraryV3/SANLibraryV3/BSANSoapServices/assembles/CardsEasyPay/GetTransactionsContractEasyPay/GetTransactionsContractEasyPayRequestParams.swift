import CoreDomain

public struct GetTransactionsContractEasyPayRequestParams {
    var token: String
    var userDataDTO: UserDataDTO
    var languageISO: String
    var dialectISO: String
    var bankCode: String
    var branchCode: String
    var product: String
    var contractNumber: String
    var dateFilter: DateFilter?
    var pagination: PaginationDTO?
}
