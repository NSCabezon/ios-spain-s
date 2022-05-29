import SANLegacyLibrary

public protocol CleanSessionUseCaseProtocol: UseCase<Void, Void, StringErrorOutput> { }

public final class CleanSessionUseCase: UseCase<Void, Void, StringErrorOutput> {
    private let provider: BSANManagersProvider

    public init(dependenciesResolver: DependenciesResolver) {
        self.provider = dependenciesResolver.resolve()
    }
    
    public override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<Void, StringErrorOutput> {
        _ = try provider.getBsanSessionManager().cleanSessionData()
        return UseCaseResponse.ok()
    }
}

extension CleanSessionUseCase: CleanSessionUseCaseProtocol { }
