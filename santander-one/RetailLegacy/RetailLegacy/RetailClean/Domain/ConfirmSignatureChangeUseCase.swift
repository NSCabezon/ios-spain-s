import Foundation
import CoreFoundationLib
import SANLegacyLibrary

class ConfirmSignatureChangeUseCase: UseCase<ConfirmSignatureChangeUseCaseInput, Void, GenericErrorSignatureErrorOutput> {
    private let provider: BSANManagersProvider
    
    init(managersProvider: BSANManagersProvider) {
        self.provider = managersProvider
    }
    
    override func executeUseCase(requestValues: ConfirmSignatureChangeUseCaseInput) throws -> UseCaseResponse<Void, GenericErrorSignatureErrorOutput> {
        guard let newSignature = requestValues.newSignature, let signatureDTO = requestValues.signatureToken?.signature.dto else {
            return UseCaseResponse.error(GenericErrorSignatureErrorOutput(nil, .otherError, nil))
        }
        let response = try provider.getBsanSignatureManager().confirmSignatureChange(newSignature: newSignature, signatureDTO: signatureDTO)
        guard response.isSuccess() else {
            let error = try response.getErrorMessage()
            let signatureType = try getSignatureResult(response)
            let errorCode = try response.getErrorCode()
            return UseCaseResponse.error(GenericErrorSignatureErrorOutput(error, signatureType, errorCode))
        }
        return UseCaseResponse.ok()
    }
}

struct ConfirmSignatureChangeUseCaseInput {
    let newSignature: String?
    let signatureToken: SignatureWithToken?
}
