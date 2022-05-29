import Foundation

public struct ActivateCardConfirmationRequestParams {
    public var token: String
    public var userDataDTO: UserDataDTO
    public var version: String
    public var terminalId: String
    public var cardPAN: String
    public var cardContractProduct: String
    public var cardContractNumber: String
    public var cardContractBranchCode: String
    public var cardBankCode: String
    public var cardExpirationDate: Date
    public var cardSignature: SignatureDTO
    public var language: String
}
