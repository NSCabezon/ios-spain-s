import CoreFoundationLib
import Foundation
import SANLegacyLibrary


class PreSetupPayLaterCardUseCase: UseCase<PreSetupPayLaterCardUseCaseInput, PreSetupPayLaterCardUseCaseOkOutput, StringErrorOutput> {
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
    
    override func executeUseCase(requestValues: PreSetupPayLaterCardUseCaseInput) throws -> UseCaseResponse<PreSetupPayLaterCardUseCaseOkOutput, StringErrorOutput> {
        
        let cards: [Card]
        if requestValues.card == nil {
            let merger = try GlobalPositionPrefsMerger(bsanManagersProvider: provider, appRepository: appRepository, accountDescriptorRepository: accountDescriptorRepository, appConfigRepository: appConfigRepository).merge()
            let enablePayLater = appConfigRepository.getAppConfigBooleanNode(nodeName: DomainConstant.appConfigCardPayLater)
            guard let pgWrapper = merger.globalPositionWrapper, enablePayLater == true else {
                return UseCaseResponse.error(StringErrorOutput(nil))
            }
            let cardList = pgWrapper.cards.getVisibles().filter({ $0.allowPayLater == true })
            guard cardList.count > 0 else {
                return UseCaseResponse.error(StringErrorOutput("deeplink_alert_errorPayLater"))
            }
            cards = cardList
        } else {
            cards = []
        }
        return UseCaseResponse.ok(PreSetupPayLaterCardUseCaseOkOutput(cards: cards))
    }
}

struct PreSetupPayLaterCardUseCaseInput {
    let card: Card?
}

struct PreSetupPayLaterCardUseCaseOkOutput {
    let cards: [Card]
}
