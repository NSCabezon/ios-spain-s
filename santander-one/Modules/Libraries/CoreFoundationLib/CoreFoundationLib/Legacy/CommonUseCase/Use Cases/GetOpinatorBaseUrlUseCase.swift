
public protocol GetOpinatorBaseUrlUseCaseProtocol: UseCase<Void, GetOpinatorBaseUrlUseCaseOutput, StringErrorOutput> { }

public class GetOpinatorBaseUrlUseCase: UseCase<Void, GetOpinatorBaseUrlUseCaseOutput, StringErrorOutput> {
    private let dependenciesResolver: DependenciesResolver
    private let urlBaseDefault = "https://www.opinator.com/opi/"
    
    public init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override public func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetOpinatorBaseUrlUseCaseOutput, StringErrorOutput> {
        if let opinatorInfoOptionProtocol: OpinatorInfoOptionProtocol = self.dependenciesResolver.resolve(forOptionalType: OpinatorInfoOptionProtocol.self) {
            return .ok(GetOpinatorBaseUrlUseCaseOutput(urlBase: opinatorInfoOptionProtocol.baseUrl))
        } else {
            return .ok(GetOpinatorBaseUrlUseCaseOutput(urlBase: urlBaseDefault))
        }
    }
}

public struct GetOpinatorBaseUrlUseCaseOutput {
    public let urlBase: String
}

extension GetOpinatorBaseUrlUseCase: GetOpinatorBaseUrlUseCaseProtocol { }
