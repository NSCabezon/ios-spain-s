import Foundation

public struct CancellationOrderRequestParams {
    public var token: String
    public var userDataDTO: UserDataDTO?
    public var terminalId: String
    public var version: String
    public var language: String
    public var bankCode: String
    public var branchCode: String
    public var product: String
    public var contractNumber: String
    public var numberOrder: String
    public var orderSignature: SignatureDTO
}
