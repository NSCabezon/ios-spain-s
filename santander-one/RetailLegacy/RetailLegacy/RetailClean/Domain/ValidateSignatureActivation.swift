import Foundation
import CoreFoundationLib
import SANLegacyLibrary

class ValidateSignatureActivationUseCase: UseCase<ValidateSignatureActivationUseCaseInput, ValidateSignatureActivationUseCaseOkOutput, ValidateSignatureActivationUseCaseErrorOutput> {
    private let provider: BSANManagersProvider
    
    init(managersProvider: BSANManagersProvider) {
        self.provider = managersProvider
    }
    
    override func executeUseCase(requestValues: ValidateSignatureActivationUseCaseInput) throws -> UseCaseResponse<ValidateSignatureActivationUseCaseOkOutput, ValidateSignatureActivationUseCaseErrorOutput> {
        guard let newSignature = requestValues.newSignature, let retypeSignature = requestValues.retypeSignature, !newSignature.isEmpty, !retypeSignature.isEmpty else {
            return UseCaseResponse.error(ValidateSignatureActivationUseCaseErrorOutput(.localValidationErrorKey("signing_alert_newSigning")))
        }
        guard newSignature == retypeSignature else {
            return UseCaseResponse.error(ValidateSignatureActivationUseCaseErrorOutput(.localValidationErrorKey("signing_alert_notMatch")))
        }
        guard let length = requestValues.newSignature?.lengthOfBytes(using: .utf8), length >= 6 else {
            return UseCaseResponse.error(ValidateSignatureActivationUseCaseErrorOutput(.localValidationErrorKey("signing_alert_validation")))
        }
        if requestValues.typeOperative == SettingOption.activateSignature {
            let response = try provider.getBsanSignatureManager().validateSignatureActivation()
            guard response.isSuccess(), let data = try response.getResponseData() else {
                let error = try response.getErrorMessage()
                return UseCaseResponse.error(ValidateSignatureActivationUseCaseErrorOutput(.serviceError(error)))
            }
            let token = SignatureWithToken(dto: data)
            return UseCaseResponse.ok(ValidateSignatureActivationUseCaseOkOutput(signatureToken: token))
        } else {
            let response = try provider.getBsanSignatureManager().consultChangeSignSignaturePositions()
            guard response.isSuccess(),
                  let scaRepresentable = try response.getResponseData()
            else {
                let error = try response.getErrorMessage()
                return UseCaseResponse.error(ValidateSignatureActivationUseCaseErrorOutput(.serviceError(error)))
            }
            let signatureToken = LegacySCAEntity(scaRepresentable).sca as? SignatureWithToken
            return UseCaseResponse.ok(ValidateSignatureActivationUseCaseOkOutput(signatureToken: signatureToken))
        }
        return UseCaseResponse.error(ValidateSignatureActivationUseCaseErrorOutput(SignatureErrorType.localValidationErrorKey("")))
    }
}

struct ValidateSignatureActivationUseCaseInput {
    let newSignature: String?
    let retypeSignature: String?
    let typeOperative: SettingOption?
}

struct ValidateSignatureActivationUseCaseOkOutput {
    let signatureToken: SignatureWithToken?
}

class ValidateSignatureActivationUseCaseErrorOutput: StringErrorOutput {
    
    let errorType: SignatureErrorType
    
    init(_ errorType: SignatureErrorType) {
        self.errorType = errorType
        if case let .serviceError(error) = errorType {
            super.init(error)
        } else {
            super.init(nil)
        }
    }
    
}

enum SignatureErrorType {
    case serviceError(String?)
    case localValidationErrorKey(String)
}
