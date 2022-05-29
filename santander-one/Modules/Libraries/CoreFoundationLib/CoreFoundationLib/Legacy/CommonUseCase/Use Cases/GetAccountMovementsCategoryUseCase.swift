import SANLegacyLibrary

public class GetAccountMovementsCategoryUseCase: UseCase<Void, GetAccountMovementsCategoryOutput, StringErrorOutput> {
    private let dependenciesResolver: DependenciesResolver
    private let provider: BSANManagersProvider
    private let appConfig: AppConfigRepositoryProtocol
    
    public init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.provider = self.dependenciesResolver.resolve(for: BSANManagersProvider.self)
        self.appConfig = self.dependenciesResolver.resolve(for: AppConfigRepositoryProtocol.self)
    }
    
    override public func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetAccountMovementsCategoryOutput, StringErrorOutput> {
        guard
            let accountMovementsCategory = appConfig.getAppConfigListNode("accountMovementsCategory"),
            !accountMovementsCategory.isEmpty
        else { return .error(StringErrorOutput("")) }
        return .ok(GetAccountMovementsCategoryOutput(accountMovementsCategory: accountMovementsCategory))
    }
}

public struct GetAccountMovementsCategoryOutput {
    public let accountMovementsCategory: [String]
}
