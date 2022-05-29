import Foundation

public struct ValidateCreateSepaPayeeRequestParams {
    public let token: String
    public let languageISO: String
    public let dialectISO: String
    public let userDataDTO: UserDataDTO
    public let beneficiary: String
    public let alias: String
    public let recipientType: String
    public let iban: IBANDTO?
    public let operationDate: Date
}
