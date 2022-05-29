import Foundation
import CoreDomain
import SANSpainLibrary

public struct ConfirmUsualTransferRequestParams {
    public var token: String
    public var userDataDTO: UserDataDTO?
    public var version: String
    public var terminalId: String
    public var language: String
    public var transferAmount: AmountDTO?
    public var originBankCode: String
    public var originBranchCode: String
    public var originProduct: String
    public var originContractNumber: String
    public var beneficiary: String
    public var beneficiaryMail: String
    public var ibandto: IBANRepresentable?
    public var concept: String
    public var signatureDTO: SignatureDTO
    public var transferType: TransferTypeDTO
    public var trusteerInfo: TrusteerInfoDTO?
}
