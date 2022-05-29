public struct ConfirmChangeDirectDebitRequestParams {
    let token: String
    let userDataDTO: UserDataDTO
    let language: String
    let dialect: String
    let signature: SignatureWithTokenDTO
    let accountDTO: AccountDTO
    let billDTO: BillDTO
}
