import Foundation

public struct ConfirmChangeAccountRequestParams {
    public var token: String
    public var userDataDTO: UserDataDTO
    public var languageISO: String
    public var dialectISO: String
    public var linkedCompany: String
    public var loanContract: ContractDTO?
    public var accountContract: ContractDTO?
    public var signature: SignatureDTO
}
