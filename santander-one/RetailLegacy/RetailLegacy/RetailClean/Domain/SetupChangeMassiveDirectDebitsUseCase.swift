import SANLegacyLibrary
import CoreFoundationLib

class SetupChangeMassiveDirectDebitsUseCase: SetupUseCase<Void, SetupChangeMassiveDirectDebitsUseCaseOKOutput, StringErrorOutput> {
    
    private let provider: BSANManagersProvider
    
    init(appConfigRepository: AppConfigRepository, bsanManagersProvider: BSANManagersProvider) {
        self.provider = bsanManagersProvider
        super.init(appConfigRepository: appConfigRepository)
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<SetupChangeMassiveDirectDebitsUseCaseOKOutput, StringErrorOutput> {
        let operativeConfig = try getOperativeConfig().getOkResult().operativeConfig
        return .ok(SetupChangeMassiveDirectDebitsUseCaseOKOutput(operativeConfig: operativeConfig))
    }
}

struct SetupChangeMassiveDirectDebitsUseCaseOKOutput {
    var operativeConfig: OperativeConfig
}

extension SetupChangeMassiveDirectDebitsUseCaseOKOutput: SetupUseCaseOkOutputProtocol {}
