import Foundation
import CoreFoundationLib
import SANLegacyLibrary

class PreSetupBillEmittersPaymentUseCase: UseCase<Void, PreSetupBillEmittersPaymentUseCaseOkOutput, StringErrorOutput> {
    
    private let dependenciesResolver: DependenciesResolver
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<PreSetupBillEmittersPaymentUseCaseOkOutput, StringErrorOutput> {
        let globalPosition = dependenciesResolver.resolve(for: GlobalPositionWithUserPrefsRepresentable.self)
        let accounts = globalPosition.accountsVisiblesWithoutPiggy
        let faqsRepository: FaqsRepositoryProtocol = self.dependenciesResolver.resolve()
        let faqs = faqsRepository.getFaqsList()?.emittersPaymentOperative?.map {
            return FaqsEntity($0)
        }
        if !accounts.isEmpty {
            return .ok(PreSetupBillEmittersPaymentUseCaseOkOutput(accounts: accounts, faqs: faqs))
        } else {
            return .error(StringErrorOutput(""))
        }
    }
}

struct PreSetupBillEmittersPaymentUseCaseOkOutput {
    let accounts: [AccountEntity]
    let faqs: [FaqsEntity]?
}
