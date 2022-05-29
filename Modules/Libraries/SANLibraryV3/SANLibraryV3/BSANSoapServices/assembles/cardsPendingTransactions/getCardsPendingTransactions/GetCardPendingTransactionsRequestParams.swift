public struct GetCardPendingTransactionsRequestParams {
    var token: String
    var userDataDTO: UserDataDTO
    var languageISO: String
    var bankCode: String
    var branchCode: String
    var product: String
    var contractNumber: String
    var dialectISO: String
    var linkedCompany: String
    var pagination: PaginationDTO?
}
