import CoreFoundationLib
import Foundation
import SANLegacyLibrary


class PreSetupChangeMassiveDirectDebitsUseCase: UseCase<Void, PreSetupChangeMassiveDirectDebitsUseCaseOkOutput, StringErrorOutput> {
    
    let appConfigRepository: AppConfigRepository
    let provider: BSANManagersProvider
    let appRepository: AppRepository
    let accountDescriptorRepository: AccountDescriptorRepository
    
    init(appConfigRepository: AppConfigRepository, bsanManagerProvider: BSANManagersProvider, appRepository: AppRepository, accountDescriptorRepository: AccountDescriptorRepository) {
        self.provider = bsanManagerProvider
        self.appConfigRepository = appConfigRepository
        self.appRepository = appRepository
        self.accountDescriptorRepository = accountDescriptorRepository
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<PreSetupChangeMassiveDirectDebitsUseCaseOkOutput, StringErrorOutput> {
        let merger = try GlobalPositionPrefsMerger(bsanManagersProvider: provider, appRepository: appRepository, accountDescriptorRepository: accountDescriptorRepository, appConfigRepository: appConfigRepository).merge()
        guard let globalPositionWrapper = merger.globalPositionWrapper else {
            return .error(StringErrorOutput(nil))
        }
        
        let accounts = globalPositionWrapper.getAccountsVisiblesWithoutPiggy
        guard accounts.count > 1 else {
            return .error(StringErrorOutput("generic_alert_text_needMinTwoAccount"))
        }
        
        return .ok(PreSetupChangeMassiveDirectDebitsUseCaseOkOutput(accounts: accounts))
    }
}

struct PreSetupChangeMassiveDirectDebitsUseCaseOkOutput {
    let accounts: [Account]
}
