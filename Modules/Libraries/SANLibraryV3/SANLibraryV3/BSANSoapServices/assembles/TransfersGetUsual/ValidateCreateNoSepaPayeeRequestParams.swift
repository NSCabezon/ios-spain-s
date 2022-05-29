//

import Foundation

public struct ValidateCreateNoSepaPayeeRequestParams {
    public let token: String
    public let userDataDTO: UserDataDTO
    public let languageISO: String
    public let dialectISO: String
    public let newAlias: String
    public let newCurrencyDTO: CurrencyDTO?
    public let noSepaPayeeDTO: NoSepaPayeeDTO?
    public let bankAddress: String
    public let bankTown: String
    public let bankCountryName: String
}
