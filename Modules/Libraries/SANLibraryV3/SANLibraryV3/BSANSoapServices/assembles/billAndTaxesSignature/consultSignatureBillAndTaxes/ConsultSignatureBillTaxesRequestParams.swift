public struct ConsultSignatureBillTaxesRequestParams {
    var token: String
    var directDebit: Bool
    var userDataDTO: UserDataDTO
    var amountValueForWS: String
    var chargeAccountBankCode: String
    var chargeAccountBranchCode: String
    var chargeAccountProduct: String
    var chargeAccountContractNumber: String
    var directDebitAccountBankCode: String
    var directDebitAccountBranchCode: String
    var directDebitAccountProduct: String
    var directDebitAccountContractNumber: String
}
