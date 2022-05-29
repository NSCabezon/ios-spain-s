//

import Foundation

public struct GetDuplicateBillRequestParams {
    let token: String
    let userDataDTO: UserDataDTO
    let language: String
    let dialect: String
    let accountDTO: AccountDTO
    let billDTO: BillDTO
    let enableBillAndTaxesRemedy: Bool
    var centro: String {
        enableBillAndTaxesRemedy ? billDTO.company.centro : billDTO.company.empresa
    }
}
