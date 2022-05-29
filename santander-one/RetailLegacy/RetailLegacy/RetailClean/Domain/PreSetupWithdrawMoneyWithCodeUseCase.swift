import SANLegacyLibrary
import CoreFoundationLib


class PreSetupWithdrawMoneyWithCodeUseCase: UseCase<PreSetupWithdrawMoneyWithCodeUseCaseInput, PreSetupWithdrawMoneyWithCodeUseCaseOkOutput, StringErrorOutput> {
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
    
    override func executeUseCase(requestValues: PreSetupWithdrawMoneyWithCodeUseCaseInput) throws -> UseCaseResponse<PreSetupWithdrawMoneyWithCodeUseCaseOkOutput, StringErrorOutput> {
        if requestValues.card != nil {
            guard let card = requestValues.card, card.allowWithdrawMoneyWithCode else {
                return UseCaseResponse.error(StringErrorOutput("deeplink_alert_errorCodeWithdraw"))
            }
            return UseCaseResponse.ok(PreSetupWithdrawMoneyWithCodeUseCaseOkOutput(cards: []))
        } else {
            let merger = try GlobalPositionPrefsMerger(bsanManagersProvider: provider, appRepository: appRepository, accountDescriptorRepository: accountDescriptorRepository, appConfigRepository: appConfigRepository).merge()
            guard let pgWrapper = merger.globalPositionWrapper else {
                return UseCaseResponse.error(StringErrorOutput(nil))
            }
            let cardList = pgWrapper.cards.getVisibles().filter {
                return $0.allowWithdrawMoneyWithCode
            }
            guard cardList.count > 0 else {
                return UseCaseResponse.error(StringErrorOutput("deeplink_alert_errorCodeWithdraw"))
            }
            return UseCaseResponse.ok(PreSetupWithdrawMoneyWithCodeUseCaseOkOutput(cards: cardList))
        }
    }
}

struct PreSetupWithdrawMoneyWithCodeUseCaseInput {
    let card: Card?
}

struct PreSetupWithdrawMoneyWithCodeUseCaseOkOutput {
    let cards: [Card]
}
