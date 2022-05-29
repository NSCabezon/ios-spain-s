import CoreFoundationLib
import Foundation
import SANLegacyLibrary


class PreSetupCardModifyPaymentFormUseCase: UseCase<PreSetupCardModifyPaymentFormUseCaseInput, PreSetupCardModifyPaymentFormUseCaseOkOutput, StringErrorOutput> {
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
    
    override func executeUseCase(requestValues: PreSetupCardModifyPaymentFormUseCaseInput) throws -> UseCaseResponse<PreSetupCardModifyPaymentFormUseCaseOkOutput, StringErrorOutput> {        
        let cards: [Card]
        if requestValues.card == nil {
            let merger = try GlobalPositionPrefsMerger(bsanManagersProvider: provider, appRepository: appRepository, accountDescriptorRepository: accountDescriptorRepository, appConfigRepository: appConfigRepository).merge()
            guard let pgWrapper = merger.globalPositionWrapper else {
                return UseCaseResponse.error(StringErrorOutput(nil))
            }
            let cardList = pgWrapper.cards.getVisibles().filter({ $0.allowsChangePayment })
            guard cardList.count > 0 else {
                return UseCaseResponse.error(StringErrorOutput("changeWayToPay_error_availableCard"))
            }
            cards = cardList
        } else {
            cards = []
        }
        return UseCaseResponse.ok(PreSetupCardModifyPaymentFormUseCaseOkOutput(cards: cards))
    }
}

struct PreSetupCardModifyPaymentFormUseCaseInput {
    let card: Card?
}

struct PreSetupCardModifyPaymentFormUseCaseOkOutput {
    let cards: [Card]
}
