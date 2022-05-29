import Foundation
import CoreFoundationLib
import SANLegacyLibrary


class GetCreditCardForPANUseCase: UseCase<GetCreditCardForPANUseCaseInput, GetCreditCardForPANUseCaseOkOutput, StringErrorOutput> {
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
    
    override public func executeUseCase(requestValues: GetCreditCardForPANUseCaseInput) throws -> UseCaseResponse<GetCreditCardForPANUseCaseOkOutput, StringErrorOutput> {
        let merger = try GlobalPositionPrefsMerger(bsanManagersProvider: provider, appRepository: appRepository, accountDescriptorRepository: accountDescriptorRepository, appConfigRepository: appConfigRepository).merge()
        guard let globalPositionWrapper = merger.globalPositionWrapper else {
            return .error(StringErrorOutput(nil))
        }
        let card = globalPositionWrapper.cards.getVisibles().first { $0.isCreditCard && $0.getDetailUI().notWhitespaces() == requestValues.pan }
        return UseCaseResponse.ok(GetCreditCardForPANUseCaseOkOutput(card: card))
    }
}

struct GetCreditCardForPANUseCaseInput {
    let pan: String
}

struct GetCreditCardForPANUseCaseOkOutput {
    let card: Card?
}
