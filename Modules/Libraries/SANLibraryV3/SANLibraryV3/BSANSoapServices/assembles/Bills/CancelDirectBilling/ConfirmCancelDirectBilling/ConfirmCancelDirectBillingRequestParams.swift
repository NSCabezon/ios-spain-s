import Foundation

public struct ConfirmCancelDirectBillingRequestParams {
    let token: String
    let userDataDTO: UserDataDTO
    let language: String
    let dialect: String
    let signature: SignatureDTO
    let accountDTO: AccountDTO
    let billDTO: BillDTO
    let getCancelDirectBillingDTO: GetCancelDirectBillingDTO
}
