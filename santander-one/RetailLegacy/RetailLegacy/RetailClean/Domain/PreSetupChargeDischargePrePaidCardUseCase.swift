import Foundation
import CoreFoundationLib
import SANLegacyLibrary


class PreSetupChargeDischargeCardUseCase: UseCase<Void, PreSetupChargeDischargeCardUseCaseOkOutput, StringErrorOutput> {
    
    private let provider: BSANManagersProvider
    private let appRepository: AppRepository
    private let appConfigRepository: AppConfigRepository
    private let accountDescriptorRepository: AccountDescriptorRepository
    
    init(bsanManagerProvider: BSANManagersProvider, appRepository: AppRepository, accountDescriptorRepository: AccountDescriptorRepository, appConfigRepository: AppConfigRepository) {
        self.provider = bsanManagerProvider
        self.appRepository = appRepository
        self.accountDescriptorRepository = accountDescriptorRepository
        self.appConfigRepository = appConfigRepository
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<PreSetupChargeDischargeCardUseCaseOkOutput, StringErrorOutput> {
        let merger = try GlobalPositionPrefsMerger(bsanManagersProvider: provider, appRepository: appRepository, accountDescriptorRepository: accountDescriptorRepository, appConfigRepository: appConfigRepository).merge()
        guard let globalPositionWrapper = merger.globalPositionWrapper
            else {
            return .error(StringErrorOutput(nil))
        }
        let accounts: [Account] = globalPositionWrapper.getAccountsVisiblesWithoutPiggy
        guard accounts.count > 0 else {
            return .error(StringErrorOutput("generic_alert_needAccountPg"))
        }
        let cards = globalPositionWrapper.cards.getVisibles().filter({ $0.allowPrepaidCharge })
        guard cards.count > 0 else {
            return .error(StringErrorOutput("deeplink_alert_errorChargeDischarge"))
        }
        return .ok(PreSetupChargeDischargeCardUseCaseOkOutput(cards: cards,
                                                              accounts: accounts))
    }
}

struct PreSetupChargeDischargeCardUseCaseOkOutput {
    let cards: [Card]
    let accounts: [Account]
}
