public struct ConfirmationBillTaxesRequestParams {
    var signatureToken: String
    var userDataDTO: UserDataDTO
    var chargeAccountBankCode: String
    var chargeAccountBranchCode: String
    var chargeAccountProduct: String
    var chargeAccountContractNumber: String
    var directDebitAccountBankCode: String
    var directDebitAccountBranchCode: String
    var directDebitAccountProduct: String
    var directDebitAccountContractNumber: String
    var billAmountValueForWS: String
    var billAmountCurrency: String
    var issuing: String
    var product: String
    var takingsType: String
    var takingsSubtype: String
    var token: String
    var formatDescriptionList: [PaymentBillTaxesItemDTO]
}
