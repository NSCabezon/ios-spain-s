public struct GetPensionContributionsRequestParams {
    var token: String
    var userDataDTO: UserDataDTO
    var bankCode: String
    var branchCode: String
    var product: String
    var contractNumber: String
    var pagination: PaginationDTO?
}
