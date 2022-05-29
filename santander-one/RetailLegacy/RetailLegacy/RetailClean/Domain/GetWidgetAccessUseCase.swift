import CoreFoundationLib

class GetWidgetAccessUseCase: UseCase<Void, GetWidgetAccessOkOutput, StringErrorOutput> {
    
    private let compilation: CompilationProtocol
    
    init(dependenciesResolver: DependenciesResolver) {
        self.compilation = dependenciesResolver.resolve(for: CompilationProtocol.self)
    }
    
    override public func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetWidgetAccessOkOutput, StringErrorOutput> {
        let query = KeychainQuery(compilation: compilation,
                                      accountPath: \.keychain.account.widget)
        do {
            let result = try KeychainWrapper().fetch(query: query) as? NSNumber.BooleanLiteralType ?? false
            return UseCaseResponse.ok(GetWidgetAccessOkOutput(isWidgetEnabled: result))
        } catch {
            return UseCaseResponse.error(StringErrorOutput(nil))
        }
    }
}

struct GetWidgetAccessOkOutput {
    let isWidgetEnabled: Bool
}
