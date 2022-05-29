import Foundation
import CoreFoundationLib
import SANLegacyLibrary

class ValidateSignUpCesCardUseCase: UseCase<ValidateSignUpCesCardUseCaseInput, ValidateSignUpCesCardUseCaseOkOutput, ValidateSignUpCesCardUseCaseErrorOutput> {
    private let provider: BSANManagersProvider
    
    init(managersProvider: BSANManagersProvider) {
        self.provider = managersProvider
    }
    
    override func executeUseCase(requestValues: ValidateSignUpCesCardUseCaseInput) throws -> UseCaseResponse<ValidateSignUpCesCardUseCaseOkOutput, ValidateSignUpCesCardUseCaseErrorOutput> {
        let response = try provider.getBsanSignatureManager().consultPensionSignaturePositions()
        
        if response.isSuccess(), let signatureWithTokenDTO = try response.getResponseData(), let signatureWithToken = SignatureWithToken(dto: signatureWithTokenDTO) {
            return UseCaseResponse.ok(ValidateSignUpCesCardUseCaseOkOutput(signatureWithToken: signatureWithToken))
        }
        return UseCaseResponse.error(ValidateSignUpCesCardUseCaseErrorOutput(try response.getErrorMessage()))
    }
}

struct ValidateSignUpCesCardUseCaseInput {
}

struct ValidateSignUpCesCardUseCaseOkOutput {
    let signatureWithToken: SignatureWithToken
}

class ValidateSignUpCesCardUseCaseErrorOutput: StringErrorOutput {
}
