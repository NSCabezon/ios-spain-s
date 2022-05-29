public struct BillAndTaxesDetailRequestParams {
    let language: String
    let token: String
    let userDataDTO: UserDataDTO
    let billDTO: BillDTO
    let accountDTO: AccountDTO
    let billOrderServiceBankCode: String
    let billOrderServiceBranchCode: String
    let billOrderServiceProduct: String
    let billOrderServiceContractNumber: String
}
