import Foundation
import SANLegacyLibrary

public class SetReadCardTransactionsUseCase: UseCase<SetReadCardTransactionsUseCaseInput, Void, StringErrorOutput> {
    
    private let managersProvider: BSANManagersProvider
    private let dependenciesResolver: DependenciesResolver
    
    public init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.managersProvider = dependenciesResolver.resolve(for: BSANManagersProvider.self)
    }
    
    override public func executeUseCase(requestValues: SetReadCardTransactionsUseCaseInput) throws -> UseCaseResponse<Void, StringErrorOutput> {
        let globalPosition = dependenciesResolver.resolve(for: GlobalPositionRepresentable.self)
        let pfmHelper = dependenciesResolver.resolve(for: PfmHelperProtocol.self)
        guard let userId = globalPosition.userCodeType else { return .error(StringErrorOutput(nil)) }
        pfmHelper.setReadMovements(for: userId, card: requestValues.card)
        return .ok()
    }
}

public struct SetReadCardTransactionsUseCaseInput {
    let card: CardEntity

    public init(card: CardEntity) {
        self.card = card
    }
}
