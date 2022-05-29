import Foundation
import CoreFoundationLib
import SANLegacyLibrary


class PreSetupCVVQueryCardUseCase: UseCase<Void, PreSetupCVVQueryCardUseCaseOkOutput, StringErrorOutput> {
    
    let appConfig: AppConfigRepository
    let provider: BSANManagersProvider
    let appRepository: AppRepository
    let appConfigRepository: AppConfigRepository
    let accountDescriptorRepository: AccountDescriptorRepository
    
    init(appConfig: AppConfigRepository, bsanManagerProvider: BSANManagersProvider, appRepository: AppRepository, accountDescriptorRepository: AccountDescriptorRepository, appConfigRepository: AppConfigRepository) {
        self.provider = bsanManagerProvider
        self.appConfig = appConfig
        self.appRepository = appRepository
        self.accountDescriptorRepository = accountDescriptorRepository
        self.appConfigRepository = appConfigRepository
        super.init()
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<PreSetupCVVQueryCardUseCaseOkOutput, StringErrorOutput> {
        let merger = try GlobalPositionPrefsMerger(bsanManagersProvider: provider, appRepository: appRepository, accountDescriptorRepository: accountDescriptorRepository, appConfigRepository: appConfigRepository).merge()
        guard let globalPositionWrapper = merger.globalPositionWrapper else {
            return .error(StringErrorOutput(nil))
        }
        let cards = globalPositionWrapper.cards.getVisibles().filter {!$0.isTemporallyOff}
        if cards.count > 0 {
            return .ok(PreSetupCVVQueryCardUseCaseOkOutput(cards: cards))
        }
        return .error(StringErrorOutput(nil))
    }
}

struct PreSetupCVVQueryCardUseCaseOkOutput {
    let cards: [Card]
}
