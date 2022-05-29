import SANLegacyLibrary
import CoreFoundationLib

class SetupUpdateUsualTransferUseCase: SetupUseCase<Void, SetupUpdateUsualTransferUseCaseOKOutput, StringErrorOutput> {
    
    private let bsanManagersProvider: BSANManagersProvider
    
    init(appConfigRepository: AppConfigRepository, bsanManagersProvider: BSANManagersProvider) {
        self.bsanManagersProvider = bsanManagersProvider
        super.init(appConfigRepository: appConfigRepository)
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<SetupUpdateUsualTransferUseCaseOKOutput, StringErrorOutput> {
        let operativeConfig = try getOperativeConfig().getOkResult().operativeConfig
        return .ok(SetupUpdateUsualTransferUseCaseOKOutput(operativeConfig: operativeConfig))
    }
}

struct SetupUpdateUsualTransferUseCaseOKOutput {
    var operativeConfig: OperativeConfig
}

extension SetupUpdateUsualTransferUseCaseOKOutput: SetupUseCaseOkOutputProtocol {}
