import Foundation
import SANLegacyLibrary

public class SetReadAccountTransactionsUseCase: UseCase<SetReadAccountTransactionsUseCaseInput, Void, StringErrorOutput> {
    
    private let managersProvider: BSANManagersProvider
    private let dependenciesResolver: DependenciesResolver
    
    public init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.managersProvider = dependenciesResolver.resolve(for: BSANManagersProvider.self)
    }
    
    override public func executeUseCase(requestValues: SetReadAccountTransactionsUseCaseInput) throws -> UseCaseResponse<Void, StringErrorOutput> {
        let globalPosition = dependenciesResolver.resolve(for: GlobalPositionRepresentable.self)
        let pfmHelper = dependenciesResolver.resolve(for: PfmHelperProtocol.self)
        guard let userId = globalPosition.userCodeType else { return .error(StringErrorOutput(nil)) }
        pfmHelper.setReadMovements(for: userId, account: requestValues.account)
        return .ok()
    }
}

public struct SetReadAccountTransactionsUseCaseInput {
    let account: AccountEntity
    
    public init(account: AccountEntity) {
        self.account = account
    }
}
