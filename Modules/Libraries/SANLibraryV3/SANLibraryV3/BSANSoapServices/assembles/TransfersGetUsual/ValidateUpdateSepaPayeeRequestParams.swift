//

import Foundation
import CoreDomain

public struct ValidateUpdateSepaPayeeRequestParams {
    public let token: String
    public let userDataDTO: UserDataDTO
    public let languageISO: String
    public let dialectISO: String
    public let payeeDTO: PayeeDTO
    public let newCurrencyDTO: CurrencyDTO?
    public let newBeneficiaryBAOName: String?
    public let newIban: IBANDTO?
}
