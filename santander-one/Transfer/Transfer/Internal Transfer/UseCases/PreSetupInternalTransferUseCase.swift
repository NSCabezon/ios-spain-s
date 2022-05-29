import Foundation
import CoreFoundationLib
import SANLegacyLibrary

public protocol PreSetupInternalTransferUseCaseProtocol: UseCase<Void, PreSetupInternalTransferUseCaseOkOutputProtocol, StringErrorOutput> {}

public protocol PreSetupInternalTransferUseCaseOkOutputProtocol {
    var accountVisibles: [AccountEntity] { get }
    var accountNotVisibles: [AccountEntity] { get }
    var faqs: [FaqsEntity]? { get }
}

final class PreSetupInternalTransferUseCase: UseCase<Void, PreSetupInternalTransferUseCaseOkOutputProtocol, StringErrorOutput> {
    
    private let dependenciesResolver: DependenciesResolver
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<PreSetupInternalTransferUseCaseOkOutputProtocol, StringErrorOutput> {
        let globalPosition = dependenciesResolver.resolve(for: GlobalPositionWithUserPrefsRepresentable.self)
        let accountsVisibles = globalPosition.accounts.visibles()
        let accountsNotVisibles = globalPosition.accounts.notVisibles
        let faqsRepository: FaqsRepositoryProtocol = self.dependenciesResolver.resolve()
        let faqs = faqsRepository.getFaqsList()?.internalTrasnferOperative?.compactMap {
            return FaqsEntity($0)
        }
        return .ok(PreSetupInternalTransferUseCaseOkOutput(
                    accountVisibles: accountsVisibles,
                    accountNotVisibles: accountsNotVisibles,
                    faqs: faqs))
    }
}

struct PreSetupInternalTransferUseCaseOkOutput {
    let accountVisibles: [AccountEntity]
    let accountNotVisibles: [AccountEntity]
    let faqs: [FaqsEntity]?
}

extension PreSetupInternalTransferUseCase: PreSetupInternalTransferUseCaseProtocol {}
extension PreSetupInternalTransferUseCaseOkOutput: PreSetupInternalTransferUseCaseOkOutputProtocol {}
