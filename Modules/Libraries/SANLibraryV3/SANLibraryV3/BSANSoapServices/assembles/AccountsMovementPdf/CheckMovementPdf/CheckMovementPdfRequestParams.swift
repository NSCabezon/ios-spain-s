import Foundation

public struct CheckMovementPdfRequestParams {
    public var token: String
    public var userDataDTO: UserDataDTO
    public var languageISO: String
    public var dialectISO: String
    public var company: String
    public var currency: String
    public var date: Date?
    public var transactionDay: String
    public var iban: IBANDTO?
}
