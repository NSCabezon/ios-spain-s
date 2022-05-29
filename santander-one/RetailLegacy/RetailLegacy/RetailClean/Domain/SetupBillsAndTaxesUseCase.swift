import CoreFoundationLib
import SANLegacyLibrary


class SetupBillsAndTaxesUseCase: SetupUseCase<Void, SetupBillsAndTaxesUseCaseOkOutput, StringErrorOutput> {
    
    init(appConfig: AppConfigRepository) {
        super.init(appConfigRepository: appConfig)
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<SetupBillsAndTaxesUseCaseOkOutput, StringErrorOutput> {
        let operativeConfig = try getOperativeConfig().getOkResult().operativeConfig
        return .ok(SetupBillsAndTaxesUseCaseOkOutput(operativeConfig: operativeConfig))
    }
}

// MARK: - OKOutput

struct SetupBillsAndTaxesUseCaseOkOutput: SetupUseCaseOkOutputProtocol {
    var operativeConfig: OperativeConfig
}
