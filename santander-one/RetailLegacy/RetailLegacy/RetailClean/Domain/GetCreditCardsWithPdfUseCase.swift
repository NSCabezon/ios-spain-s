import Foundation
import CoreFoundationLib
import SANLegacyLibrary


class GetCreditCardsWithPdfUseCase: UseCase<Void, GetCreditCardsWithPdfUseCaseOkOutput, StringErrorOutput> {
    
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
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetCreditCardsWithPdfUseCaseOkOutput, StringErrorOutput> {
        let merger = try GlobalPositionPrefsMerger(bsanManagersProvider: provider, appRepository: appRepository, accountDescriptorRepository: accountDescriptorRepository, appConfigRepository: appConfigRepository).merge()
        guard let globalPositionWrapper = merger.globalPositionWrapper else {
            return .error(StringErrorOutput(nil))
        }
        let cards = globalPositionWrapper.cards.getVisibles().filter({ $0.isCreditCard && $0.isCardContractHolder && $0.isActive && !$0.isTemporallyOff})
        guard cards.count > 0 else {
            return .error(StringErrorOutput("deeplink_alert_errorPdfExtract"))
        }
        return .ok(GetCreditCardsWithPdfUseCaseOkOutput(cards: cards))
    }
}

struct GetCreditCardsWithPdfUseCaseOkOutput {
    let cards: [Card]
}
