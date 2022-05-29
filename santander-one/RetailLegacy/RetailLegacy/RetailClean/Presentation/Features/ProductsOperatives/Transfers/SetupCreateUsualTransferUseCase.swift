import SANLegacyLibrary
import CoreFoundationLib

class SetupCreateUsualTransferUseCase: SetupUseCase<SetupCreateUsualTransferUseCaseInput, SetupCreateUsualTransferUseCaseOKOutput, StringErrorOutput> {
    
    private let bsanManagersProvider: BSANManagersProvider
    
    init(appConfigRepository: AppConfigRepository, bsanManagersProvider: BSANManagersProvider) {
        self.bsanManagersProvider = bsanManagersProvider
        super.init(appConfigRepository: appConfigRepository)
    }
    
    override func executeUseCase(requestValues: SetupCreateUsualTransferUseCaseInput) throws -> UseCaseResponse<SetupCreateUsualTransferUseCaseOKOutput, StringErrorOutput> {
        let operativeConfig = try getOperativeConfig().getOkResult().operativeConfig
        return .ok(SetupCreateUsualTransferUseCaseOKOutput(operativeConfig: operativeConfig))
    }
}

struct SetupCreateUsualTransferUseCaseInput {
}

struct SetupCreateUsualTransferUseCaseOKOutput {
    var operativeConfig: OperativeConfig
}

extension SetupCreateUsualTransferUseCaseOKOutput: SetupUseCaseOkOutputProtocol {}
