import Foundation
import CoreDomain

public struct ValidateUsualTransferRequestParams {
    public var token: String
    public var userDataDTO: UserDataDTO?
    public var version: String
    public var terminalId: String
    public var language: String
    public var beneficiary: String
    public var ibandto: IBANRepresentable?
    public var transferAmount: AmountDTO?
    public var bankCode: String
    public var branchCode: String
    public var product: String
    public var contractNumber: String
    public var concept: String
    public var transferType: TransferTypeDTO
}
