import Foundation
import CoreFoundationLib
import SANLegacyLibrary


final class PreSetupDirectMoneyUseCase: UseCase<Void, PreSetupDirectMoneyUseCaseOkOutput, StringErrorOutput> {
    
    private let provider: BSANManagersProvider
    private let appRepository: AppRepository
    private let accountDescriptorRepository: AccountDescriptorRepository
    private let appConfigRepository: AppConfigRepository
    
    init(managersProvider: BSANManagersProvider, appConfigRepository: AppConfigRepository, appRepository: AppRepository, accountDescriptorRepository: AccountDescriptorRepository) {
        self.provider = managersProvider
        self.appRepository = appRepository
        self.accountDescriptorRepository = accountDescriptorRepository
        self.appConfigRepository = appConfigRepository
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<PreSetupDirectMoneyUseCaseOkOutput, StringErrorOutput> {
        let merger = try GlobalPositionPrefsMerger(bsanManagersProvider: provider, appRepository: appRepository, accountDescriptorRepository: accountDescriptorRepository, appConfigRepository: appConfigRepository).merge()
        let enableDirectMoney = appConfigRepository.getAppConfigBooleanNode(nodeName: DomainConstant.appConfigCardDirectMoney)
        guard let pgWrapper = merger.globalPositionWrapper, enableDirectMoney == true else {
            return UseCaseResponse.error(StringErrorOutput(nil))
        }
        let cardList = pgWrapper.cards.getVisibles().filter({ $0.allowDirectMoney == true && !$0.isTemporallyOff && $0.isActive })
        guard cardList.count > 0 else {
            return UseCaseResponse.error(StringErrorOutput("deeplink_alert_errorDirectMoney"))
        }
        
        return UseCaseResponse.ok(PreSetupDirectMoneyUseCaseOkOutput(cardList: cardList))
    }
}

struct PreSetupDirectMoneyUseCaseOkOutput {
    let cardList: [Card]
}
