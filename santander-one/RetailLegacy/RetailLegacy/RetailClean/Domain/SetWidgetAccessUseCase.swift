import CoreFoundationLib

class SetWidgetAccessUseCase: UseCase<SetWidgetAccessInput, Void, SetWidgetAccessErrorOutput> {
    
    private let compilation: CompilationProtocol
    
    init(dependenciesResolver: DependenciesResolver) {
        self.compilation = dependenciesResolver.resolve(for: CompilationProtocol.self)
    }
    
    override public func executeUseCase(requestValues: SetWidgetAccessInput) throws -> UseCaseResponse<Void, SetWidgetAccessErrorOutput> {
        let query = KeychainQuery(compilation: compilation,
                                      accountPath: \.keychain.account.widget,
                                      data: NSNumber(value: requestValues.isWidgetEnabled))
        do {
            try KeychainWrapper().save(query: query)
            return UseCaseResponse.ok()
        } catch {
            return UseCaseResponse.error(SetWidgetAccessErrorOutput(nil))
        }
    }
}

struct SetWidgetAccessInput {
    let isWidgetEnabled: Bool
}

class SetWidgetAccessErrorOutput: StringErrorOutput {
}
