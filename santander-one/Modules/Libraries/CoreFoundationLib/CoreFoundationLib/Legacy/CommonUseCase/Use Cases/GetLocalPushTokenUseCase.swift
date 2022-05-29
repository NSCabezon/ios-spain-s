
public class GetLocalPushTokenUseCase: UseCase<Void, GetLocalPushTokenUseCaseOkOutput, StringErrorOutput> {
    private let compilation: CompilationProtocol
    
    public init(dependenciesResolver: DependenciesResolver) {
        self.compilation = dependenciesResolver.resolve(for: CompilationProtocol.self)
    }
    
    override public func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetLocalPushTokenUseCaseOkOutput, StringErrorOutput> {
        let lookupQuery = KeychainQuery(compilation: compilation,
                                        accountPath: \.keychain.account.tokenPush)
        do {
            let tokenPush = try KeychainWrapper().fetch(query: lookupQuery) as? Data
            return UseCaseResponse.ok(GetLocalPushTokenUseCaseOkOutput(tokenPush: tokenPush))
        } catch {
            return UseCaseResponse.ok(GetLocalPushTokenUseCaseOkOutput(tokenPush: nil))
        }
    }
}

public struct GetLocalPushTokenUseCaseOkOutput {
    public let tokenPush: Data?
    public var toStringTokenPush: String? {
        guard let tokenPush = tokenPush else { return nil }
        return tokenPush.map { String(format: "%02.2hhx", $0) }.joined()
    }
}
