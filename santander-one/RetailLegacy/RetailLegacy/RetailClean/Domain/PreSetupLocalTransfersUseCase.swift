import Foundation
import CoreFoundationLib
import SANLegacyLibrary


class PreSetupLocalTransfersUseCase: UseCase<Void, PreSetupLocalTransfersUseCaseOkOutput, StringErrorOutput> {
    
    let provider: BSANManagersProvider
    let appRepository: AppRepository
    let appConfigRepository: AppConfigRepository
    let accountDescriptorRepository: AccountDescriptorRepository
    
    init(bsanManagerProvider: BSANManagersProvider, appRepository: AppRepository, accountDescriptorRepository: AccountDescriptorRepository, appConfigRepository: AppConfigRepository) {
        self.provider = bsanManagerProvider
        self.appRepository = appRepository
        self.accountDescriptorRepository = accountDescriptorRepository
        self.appConfigRepository = appConfigRepository
        super.init()
    }
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<PreSetupLocalTransfersUseCaseOkOutput, StringErrorOutput> {
        let merger = try GlobalPositionPrefsMerger(bsanManagersProvider: provider, appRepository: appRepository, accountDescriptorRepository: accountDescriptorRepository, appConfigRepository: appConfigRepository).merge()
        guard let globalPositionWrapper = merger.globalPositionWrapper else {
            return .error(StringErrorOutput(nil))
        }
        let accounts = globalPositionWrapper.getAccountsVisiblesWithoutPiggy
        let allAccounts = globalPositionWrapper.getAllAccountsWithoutPiggy
        switch allAccounts.count {
        case 0: return .error(StringErrorOutput("transfer_alert_twoAccount"))
        case 1: return .error(StringErrorOutput("transfer_alert_onlyAccount"))
        default: return .ok(PreSetupLocalTransfersUseCaseOkOutput(accounts: allAccounts))
        }
    }
}

struct PreSetupLocalTransfersUseCaseOkOutput {
    let accounts: [Account]
}
