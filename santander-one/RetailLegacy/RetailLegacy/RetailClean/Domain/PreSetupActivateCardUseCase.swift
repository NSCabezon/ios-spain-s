import Foundation
import CoreFoundationLib
import SANLegacyLibrary


class PreSetupActivateCardUseCase: UseCase<Void, PreSetupActivateCardUseCaseOkOutput, StringErrorOutput> {
    
    private let appConfig: AppConfigRepository
    private let provider: BSANManagersProvider
    private let appRepository: AppRepository
    private let appConfigRepository: AppConfigRepository
    private let accountDescriptorRepository: AccountDescriptorRepository
    
    init(appConfig: AppConfigRepository, bsanManagerProvider: BSANManagersProvider, appRepository: AppRepository, accountDescriptorRepository: AccountDescriptorRepository, appConfigRepository: AppConfigRepository) {
        self.provider = bsanManagerProvider
        self.appConfig = appConfig
        self.appRepository = appRepository
        self.accountDescriptorRepository = accountDescriptorRepository
        self.appConfigRepository = appConfigRepository
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<PreSetupActivateCardUseCaseOkOutput, StringErrorOutput> {
        let merger = try GlobalPositionPrefsMerger(bsanManagersProvider: provider, appRepository: appRepository, accountDescriptorRepository: accountDescriptorRepository, appConfigRepository: appConfigRepository).merge()
        guard let globalPositionWrapper = merger.globalPositionWrapper else {
            return .error(StringErrorOutput(nil))
        }
        let cards = globalPositionWrapper.cards.getVisibles().filter({ !$0.isActive })
        if cards.count > 0 {
            return .ok(PreSetupActivateCardUseCaseOkOutput(cards: cards))
        }
        return .error(StringErrorOutput(nil))
    }
}

struct PreSetupActivateCardUseCaseOkOutput {
    let cards: [Card]
}
