import Foundation

public struct DownloadPdfBillRequestParams {
    let token: String
    let userDataDTO: UserDataDTO
    let language: String
    let dialect: String
    let accountDTO: AccountDTO
    let billDTO: BillDTO
    let enableBillAndTaxesRemedy: Bool
    var company: String {
        enableBillAndTaxesRemedy ? billDTO.creditorCompanyId : billDTO.company.empresa
    }
    var centro: String {
        enableBillAndTaxesRemedy ? billDTO.company.centro : billDTO.company.empresa
    }
}
