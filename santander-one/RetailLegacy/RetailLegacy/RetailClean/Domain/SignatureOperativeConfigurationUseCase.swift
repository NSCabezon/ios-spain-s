import SANLegacyLibrary
import CoreFoundationLib

class SignatureOperativeConfigurationUseCase: SetupUseCase<Void, SignatureOperativeConfigurationUseCaseOkOutput, StringErrorOutput> {
    private let provider: BSANManagersProvider
    
    init(managersProvider: BSANManagersProvider, appConfigRepository: AppConfigRepository) {
        self.provider = managersProvider
        super.init(appConfigRepository: appConfigRepository)
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<SignatureOperativeConfigurationUseCaseOkOutput, StringErrorOutput> {
        let operativeConfig = try getOperativeConfig().getOkResult().operativeConfig
        let bsanResponse = try provider.getBsanSignatureManager().loadCMCSignature()
        let signatureInfo = try provider.getBsanSignatureManager().getCMCSignature()
        guard bsanResponse.isSuccess(), signatureInfo.isSuccess(),
            let data = try signatureInfo.getResponseData() else {
                return UseCaseResponse.error(StringErrorOutput("signatureKey_error_activate"))
        }
        let signatureData = SignatureData(signatureDataDTO: data.signatureDataDTO)
        let isSignatureActivationPending = signatureData.isSignatureActivationPending()
        let output = SignatureOperativeConfigurationUseCaseOkOutput(operativeConfig: operativeConfig,
                                                                    isSignatureActivationPending: isSignatureActivationPending)
        return UseCaseResponse.ok(output)
    }
}

struct SignatureOperativeConfigurationUseCaseOkOutput: SetupUseCaseOkOutputProtocol {
    var operativeConfig: OperativeConfig
    let isSignatureActivationPending: Bool
}
