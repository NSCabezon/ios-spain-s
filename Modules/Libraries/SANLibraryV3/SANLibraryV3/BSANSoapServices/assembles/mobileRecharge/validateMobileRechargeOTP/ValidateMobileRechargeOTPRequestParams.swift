public struct ValidateMobileRechargeOTPRequestParams {
    var token: String
    var userDataDTO: UserDataDTO
    var languageISO: String
    var dialectISO: String
    var linkedCompany: String
    var cardContract: ContractDTO
    var signature: SignatureWithTokenDTO
    var mobile: String
    var amount: AmountDTO
    var mobileOperatorCode: String
}
