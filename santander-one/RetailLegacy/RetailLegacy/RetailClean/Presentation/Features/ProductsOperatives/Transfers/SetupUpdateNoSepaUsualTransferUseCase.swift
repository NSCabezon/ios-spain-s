import SANLegacyLibrary
import CoreFoundationLib

class SetupUpdateNoSepaUsualTransferUseCase: SetupUseCase<SetupUpdateNoSepaUsualTransferUseCaseInput, SetupUpdateNoSepaUsualTransferUseCaseOKOutput, StringErrorOutput> {
    
    private let bsanManagersProvider: BSANManagersProvider
    
    init(appConfigRepository: AppConfigRepository, bsanManagersProvider: BSANManagersProvider) {
        self.bsanManagersProvider = bsanManagersProvider
        super.init(appConfigRepository: appConfigRepository)
    }
    
    override func executeUseCase(requestValues: SetupUpdateNoSepaUsualTransferUseCaseInput) throws -> UseCaseResponse<SetupUpdateNoSepaUsualTransferUseCaseOKOutput, StringErrorOutput> {
        let operativeConfig = try getOperativeConfig().getOkResult().operativeConfig
        return .ok(SetupUpdateNoSepaUsualTransferUseCaseOKOutput(operativeConfig: operativeConfig))
    }
}

struct SetupUpdateNoSepaUsualTransferUseCaseInput {
}

struct SetupUpdateNoSepaUsualTransferUseCaseOKOutput {
    var operativeConfig: OperativeConfig
}

extension SetupUpdateNoSepaUsualTransferUseCaseOKOutput: SetupUseCaseOkOutputProtocol {}
