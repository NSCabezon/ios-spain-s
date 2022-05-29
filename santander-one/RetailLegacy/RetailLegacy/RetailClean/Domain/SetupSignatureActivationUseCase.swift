import SANLegacyLibrary
import CoreFoundationLib

class SetupSignatureUseCase: SetupUseCase<SetupSignatureUseCaseInput, SetupSignatureUseCaseOkOutput, StringErrorOutput> {
    
    private let provider: BSANManagersProvider
    
    init(managersProvider: BSANManagersProvider, appConfigRepository: AppConfigRepository) {
        self.provider = managersProvider
        super.init(appConfigRepository: appConfigRepository)
    }
    
    override func executeUseCase(requestValues: SetupSignatureUseCaseInput) throws -> UseCaseResponse<SetupSignatureUseCaseOkOutput, StringErrorOutput> {
        let operativeConfig = try getOperativeConfig().getOkResult().operativeConfig
        
        if requestValues.settingOption == .activateSignature {
            let loadResponse = try provider.getBsanSignatureManager().loadCMCSignature()
            
            guard loadResponse.isSuccess() else {
                return UseCaseResponse.error(StringErrorOutput(try loadResponse.getErrorMessage()))
            }
            
            let cmcResponse = try provider.getBsanSignatureManager().getCMCSignature()
            
            guard cmcResponse.isSuccess(), let data = try cmcResponse.getResponseData() else {
                return UseCaseResponse.error(StringErrorOutput(try cmcResponse.getErrorMessage()))
            }
            
            let signatureData = SignatureData(signatureDataDTO: data.signatureDataDTO)
            guard signatureData.isSignatureActivationPending() else {
                return UseCaseResponse.error(StringErrorOutput("signing_alert_newValidation"))
            }
        }
        
        return UseCaseResponse.ok(SetupSignatureUseCaseOkOutput(operativeConfig: operativeConfig))
    }
}

struct SetupSignatureUseCaseInput {
    let settingOption: SettingOption
}

struct SetupSignatureUseCaseOkOutput: SetupUseCaseOkOutputProtocol {
    var operativeConfig: OperativeConfig
}
