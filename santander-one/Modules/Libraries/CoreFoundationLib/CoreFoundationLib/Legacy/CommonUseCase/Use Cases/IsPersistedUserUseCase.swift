
public final class IsPersistedUserUseCase: UseCase<Void, Void, StringErrorOutput> {
    private let dependenciesResolver: DependenciesResolver
    
    public init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override public func executeUseCase(requestValues: Void) throws -> UseCaseResponse<Void, StringErrorOutput> {
        let appRepositoy: AppRepositoryProtocol = dependenciesResolver.resolve()
        let response = appRepositoy.hasPersistedUser()
        guard response.isSuccess(), try response.getResponseData() == true else {
            return .error(StringErrorOutput(nil))
        }
        return .ok()
    }
}
