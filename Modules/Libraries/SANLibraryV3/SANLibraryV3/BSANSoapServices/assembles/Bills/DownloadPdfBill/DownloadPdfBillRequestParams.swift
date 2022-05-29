import Foundation

public struct DownloadPdfBillRequestParams {
    let token: String
    let userDataDTO: UserDataDTO
    let language: String
    let dialect: String
    let accountDTO: AccountDTO
    let billDTO: BillDTO
    let enableBillAndTaxesRemedy: Bool
    var center: String {
        enableBillAndTaxesRemedy ? billDTO.company.centro : billDTO.creditorCenterId
    }
    var company: String {
        enableBillAndTaxesRemedy ? billDTO.creditorCompanyId : billDTO.creditorCenterId
    }
}
