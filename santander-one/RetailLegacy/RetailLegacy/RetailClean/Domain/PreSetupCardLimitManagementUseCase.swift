import Foundation
import CoreFoundationLib
import SANLegacyLibrary


class PreSetupCardLimitManagementUseCase: UseCase<PreSetupCardLimitManagementUseCaseInput, PreSetupCardLimitManagementUseCaseOkOutput, StringErrorOutput> {
    
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
    
    override func executeUseCase(requestValues: PreSetupCardLimitManagementUseCaseInput) throws -> UseCaseResponse<PreSetupCardLimitManagementUseCaseOkOutput, StringErrorOutput> {
        if requestValues.card != nil {
            return .ok(PreSetupCardLimitManagementUseCaseOkOutput(cards: []))
        }
        let merger = try GlobalPositionPrefsMerger(bsanManagersProvider: provider, appRepository: appRepository, accountDescriptorRepository: accountDescriptorRepository, appConfigRepository: appConfigRepository).merge()
        guard let globalPositionWrapper = merger.globalPositionWrapper else {
            return .error(StringErrorOutput(nil))
        }
        let isEnabledSuperspeed = appConfigRepository.getAppConfigBooleanNode(nodeName: DomainConstant.appConfigEnableCardSuperSpeed) ?? false
        if isEnabledSuperspeed {
            let cards = globalPositionWrapper.cards.getVisibles().filter({ $0.isCreditCard || $0.isDebitCard })
            if cards.count > 0 {
                return .ok(PreSetupCardLimitManagementUseCaseOkOutput(cards: cards))
            }
        }
        return .error(StringErrorOutput(nil))
    }
}

struct PreSetupCardLimitManagementUseCaseInput {
    let card: Card?
}

struct PreSetupCardLimitManagementUseCaseOkOutput {
    let cards: [Card]
}
