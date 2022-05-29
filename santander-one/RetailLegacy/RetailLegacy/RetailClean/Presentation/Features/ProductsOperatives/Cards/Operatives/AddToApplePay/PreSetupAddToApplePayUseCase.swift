import CoreFoundationLib
import Foundation
import SANLegacyLibrary


class PreSetupAddToApplePayUseCase: UseCase<Void, PreSetupAddToApplePayUseCaseOkOutput, StringErrorOutput> {
    private let provider: BSANManagersProvider
    private let appConfigRepository: AppConfigRepository
    private let appRepository: AppRepository
    private let accountDescriptorRepository: AccountDescriptorRepository
    
    init(provider: BSANManagersProvider,
         appConfigRepository: AppConfigRepository,
         appRepository: AppRepository,
         accountDescriptorRepository: AccountDescriptorRepository) {
        self.provider = provider
        self.appRepository = appRepository
        self.appConfigRepository = appConfigRepository
        self.accountDescriptorRepository = accountDescriptorRepository
    }
    
    override func executeUseCase(requestValues: Void)
        throws -> UseCaseResponse<PreSetupAddToApplePayUseCaseOkOutput, StringErrorOutput> {
        guard appConfigRepository.getBool("enableInAppEnrollment") == true else { return .error(StringErrorOutput(nil)) }
        let merger = try GlobalPositionPrefsMerger(
            bsanManagersProvider: provider,
            appRepository: appRepository,
            accountDescriptorRepository: accountDescriptorRepository,
            appConfigRepository: appConfigRepository)
            .merge()
        
        guard let globalWrapper = merger.globalPositionWrapper else {
            return .error(StringErrorOutput("deeplink_alert_addCard"))
        }
        
        let enrolledCards = try provider
            .getBsanCardsManager()
            .getCardApplePayStatus()
            .getResponseData() ?? [:]
            
        let cards = globalWrapper.cards
            .getVisibles()
            .filter({ allowCard($0, enrolledCards: enrolledCards) })

        guard !cards.isEmpty else {
            return .error(StringErrorOutput("deeplink_alert_addCard"))
        }
        
        return .ok(PreSetupAddToApplePayUseCaseOkOutput(cards: cards))
    }
    
    private func allowCard(_ card: Card, enrolledCards: [String: CardApplePayStatusDTO]) -> Bool {
        guard !card.isTemporallyOff, !card.isContractBlocked, !card.isPrepaidCard else { return false }
        let pan = card.productIdentifier.replace(" ", "")
        return enrolledCards[pan] == nil || enrolledCards[pan]?.status != .active
    }
}

struct PreSetupAddToApplePayUseCaseOkOutput {
    let cards: [Card]
}
