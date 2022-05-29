import CoreFoundationLib

public protocol SetTransferHomeUseCaseProtocol: UseCase<Void, SetTransferHomeUseCaseCaseOutput, StringErrorOutput> {}

public final class SetTransferHomeUseCase: UseCase<Void, SetTransferHomeUseCaseCaseOutput, StringErrorOutput> {
    let dependencies: DependenciesResolver
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependencies = dependenciesResolver
    }
    
    public override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<SetTransferHomeUseCaseCaseOutput, StringErrorOutput> {
        let globalPosition = dependencies.resolve(for: GlobalPositionWithUserPrefsRepresentable.self)
        let isTransferBetweenAccountsAvailable: Bool = globalPosition.accounts.all().count >= 2
        return .ok(SetTransferHomeUseCaseCaseOutput(isTransferBetweenAccountsAvailable: isTransferBetweenAccountsAvailable))
    }
}

public struct SetTransferHomeUseCaseCaseOutput {
    public var isTransferBetweenAccountsAvailable: Bool
    
    public init(isTransferBetweenAccountsAvailable: Bool) {
        self.isTransferBetweenAccountsAvailable = isTransferBetweenAccountsAvailable
    }
}

extension SetTransferHomeUseCase: SetTransferHomeUseCaseProtocol {}
