import Foundation

public struct ConfirmPayLaterRequestParams {
    var token: String
    var userDataDTO: UserDataDTO
    var languageISO: String
    var dialectISO: String
    var linkedCompany: String
    var bankCode: String
    var branchCode: String
    var product: String
    var contractNumber: String
    var operationDate: Date
    var amountValue: String
    var currency: String
}
