import CoreFoundationLib
import SANLegacyLibrary

class ValidateEnableOtpPushUseCase: UseCase<Void, ValidateEnableOtpPushUseCaseOkOutput, GenericUseCaseErrorOutput> {
    private let provider: BSANManagersProvider
    
    init(managersProvider: BSANManagersProvider) {
        self.provider = managersProvider
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<ValidateEnableOtpPushUseCaseOkOutput, GenericUseCaseErrorOutput> {
        let response = try provider.getBsanSignatureManager().requestOTPPushRegisterDevicePositions()
        
        guard response.isSuccess(), let data = try response.getResponseData() else {
            return .error(GenericUseCaseErrorOutput(try response.getErrorMessage(), try response.getErrorCode()))
        }
        
        let token = SignatureWithToken(dto: data)
        
        return UseCaseResponse.ok(ValidateEnableOtpPushUseCaseOkOutput(signatureToken: token))
    }
}

struct ValidateEnableOtpPushUseCaseOkOutput {
    let signatureToken: SignatureWithToken?
}
