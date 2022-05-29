//

import Foundation

public struct GetCancelDirectBillingRequestParams {
    let token: String
    let userDataDTO: UserDataDTO
    let language: String
    let dialect: String
    let accountDTO: AccountDTO
    let billDTO: BillDTO
    let enableBillAndTaxesRemedy: Bool
    var centro: String? {
        enableBillAndTaxesRemedy ? billDTO.company.centro : nil
    }
}
