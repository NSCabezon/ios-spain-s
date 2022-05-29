//

import Foundation

public struct ValidateUpdateNoSepaPayeeRequestParams {
    public let token: String
    public let userDataDTO: UserDataDTO
    public let languageISO: String
    public let dialectISO: String
    public let alias: String
    public let noSepaPayeeDTO: NoSepaPayeeDTO?
    public let newCurrencyDTO: CurrencyDTO?
    public let bankAddress: String
    public let bankTown: String
    public let bankCountryName: String
}
