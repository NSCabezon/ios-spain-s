import Foundation

struct ConfirmSanKeyTransferRequestParams {
     var token: String
     var userDataDTO: UserDataDTO?
     var version: String
     var terminalId: String
     var language: String
     var beneficiary: String
     var isSpanishResidentBeneficiary: Bool
     var saveAsUsualAlias: String?
     var saveAsUsual: Bool
     var beneficiaryMail: String
     var ibandto: IBANDTO
     var transferAmount: AmountDTO
     var bankCode: String
     var branchCode: String
     var product: String
     var contractNumber: String
     var concept: String
     var otpTicket: String
     var otpToken: String
     var otpCode: String
     var transferType: TransferTypeDTO
     let trusteerInfo: TrusteerInfoDTO?
     let tokenSteps: String
}
