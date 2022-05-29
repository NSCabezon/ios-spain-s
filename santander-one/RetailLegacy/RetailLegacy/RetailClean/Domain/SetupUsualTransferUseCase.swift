import CoreFoundationLib
import SANLegacyLibrary


class SetupUsualTransferUseCase: SetupUseCase<Void, SetupUsualTransferUseCaseOkOutput, StringErrorOutput> {
    
    private let provider: BSANManagersProvider
    private let appRepository: AppRepository
    private let accountDescriptorRepository: AccountDescriptorRepository

    init(managersProvider: BSANManagersProvider, appConfigRepository: AppConfigRepository, appRepository: AppRepository, accountDescriptorRepository: AccountDescriptorRepository) {
        self.provider = managersProvider
        self.appRepository = appRepository
        self.accountDescriptorRepository = accountDescriptorRepository
        super.init(appConfigRepository: appConfigRepository)
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<SetupUsualTransferUseCaseOkOutput, StringErrorOutput> {
        let merger = try GlobalPositionPrefsMerger(bsanManagersProvider: provider, appRepository: appRepository, accountDescriptorRepository: accountDescriptorRepository, appConfigRepository: appConfigRepository).merge()
        guard let pgWrapper = merger.globalPositionWrapper else {
            return UseCaseResponse.error(StringErrorOutput(nil))
        }
        let operativeConfig = try getOperativeConfig().getOkResult().operativeConfig
        let amount: Amount?
        if let max = appConfigRepository.getAppConfigDecimalNode(nodeName: DomainConstant.appConfigInstantNationalTransfersMaxAmount) {
            amount = Amount.createWith(value: max)
        } else {
            amount = nil
        }
        return UseCaseResponse.ok(SetupUsualTransferUseCaseOkOutput(operativeConfig: operativeConfig, maxAmount: amount, payer: pgWrapper.name.camelCasedString))
    }
}

struct SetupUsualTransferUseCaseOkOutput {
    var operativeConfig: OperativeConfig
    let maxAmount: Amount?
    let payer: String
}

extension SetupUsualTransferUseCaseOkOutput: SetupUseCaseOkOutputProtocol {}
