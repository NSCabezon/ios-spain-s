import Foundation

public struct ValidateGenericTransferOTPRequestParams {
    public let token: String
    public let userDataDTO: UserDataDTO?
    public let version: String
    public let terminalId: String
    public let ibandto: IBANDTO
    public let transferAmount: AmountDTO
    public let bankCode: String
    public let branchCode: String
    public let product: String
    public let contractNumber: String
    public let signatureDTO: SignatureDTO
    public let language: String
    public let dialectISO: String
}
