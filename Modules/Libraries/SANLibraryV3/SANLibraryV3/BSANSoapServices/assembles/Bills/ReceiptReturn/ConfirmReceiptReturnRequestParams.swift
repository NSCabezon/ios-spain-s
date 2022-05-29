public struct ConfirmReceiptReturnRequestParams {
    let token: String
    let userDataDTO: UserDataDTO
    let language: String
    let signature: SignatureDTO
    let accountDTO: AccountDTO
    let billDTO: BillDTO
    let billDetaildDTO: BillDetailDTO
    let enableBillAndTaxesRemedy: Bool
    var centro: String {
        enableBillAndTaxesRemedy ? billDTO.company.centro : billDTO.company.empresa
    }
}
