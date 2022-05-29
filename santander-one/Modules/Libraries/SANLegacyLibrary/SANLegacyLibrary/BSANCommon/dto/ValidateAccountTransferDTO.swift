import CoreDomain
import Foundation

public struct ValidateAccountTransferDTO {
    public var transferNationalDTO: TransferNationalDTO?
    public var errorCode: String?

    public init() {}
    
    public init(transferNationalDTO: TransferNationalDTO? = nil, errorCode: String? = nil) {
        self.transferNationalDTO = transferNationalDTO
        self.errorCode = errorCode
    }
}

extension ValidateAccountTransferDTO: ValidateAccountTransferRepresentable {
    public var transferNationalRepresentable: TransferNationalRepresentable? {
        return transferNationalDTO
    }
}
