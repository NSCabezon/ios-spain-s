import CoreFoundationLib
import SANLegacyLibrary

protocol ValidateTransferUseCaseOkOutput {
    var beneficiaryMail: String? { get }
    var scaEntity: LegacySCAEntity { get }
}

enum ValidateTransferError {
    case invalidEmail
    case serviceError(errorDesc: String?)
}

class ValidateTransferUseCaseErrorOutput: StringErrorOutput {
    let error: ValidateTransferError
    
    init(_ error: ValidateTransferError) {
        self.error = error
        super.init("")
    }
}
