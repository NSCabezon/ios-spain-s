import CoreFoundationLib
import SANLegacyLibrary


class SetupLocalTransfersUseCase: SetupUseCase<Void, SetupLocalTransfersUseCaseOkOutput, StringErrorOutput> {
    
    init(appConfig: AppConfigRepository) {
        super.init(appConfigRepository: appConfig)
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<SetupLocalTransfersUseCaseOkOutput, StringErrorOutput> {
        let operativeConfig = try getOperativeConfig().getOkResult().operativeConfig
        return .ok(SetupLocalTransfersUseCaseOkOutput(operativeConfig: operativeConfig))
    }
}

// MARK: - OKOutput

struct SetupLocalTransfersUseCaseOkOutput: SetupUseCaseOkOutputProtocol {
    var operativeConfig: OperativeConfig
}
