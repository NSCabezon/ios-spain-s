import Foundation

public struct CheckEntityAdheredRequestParams {
    public var token: String
    public var userDataDTO: UserDataDTO
    public var languageISO: String
    public var dialectISO: String
    public var linkedCompany: String
    public var ibanTransferencia: IBANDTO?
    public var company: String
}
