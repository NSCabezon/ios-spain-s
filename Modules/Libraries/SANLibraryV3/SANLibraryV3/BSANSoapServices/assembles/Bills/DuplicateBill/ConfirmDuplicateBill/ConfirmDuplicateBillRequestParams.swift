import Foundation

public struct ConfirmDuplicateBillRequestParams {
    let token: String
    let userDataDTO: UserDataDTO
    let language: String
    let dialect: String
    let signature: SignatureDTO
    let accountDTO: AccountDTO
    let billDTO: BillDTO
    let enableBillAndTaxesRemedy: Bool
    var centro: String {
        enableBillAndTaxesRemedy ? billDTO.company.centro : billDTO.company.empresa
    }
}
