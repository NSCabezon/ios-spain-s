import CoreFoundationLib

public class LocalAuthLoginDataUseCase<Input, OkOutput, ErrorOutput: StringErrorOutput>: UseCase<Input, OkOutput, ErrorOutput> {
    
    private let compilation: CompilationProtocol
    
    init(dependenciesResolver: DependenciesResolver) {
        self.compilation = dependenciesResolver.resolve(for: CompilationProtocol.self)
    }
    
    public func getLocalAuthData(requestValues: Input) -> TouchIdData? {
        return KeychainWrapper().touchIdData(compilation: compilation)
    }
    
    public func getLocalWidgetEnabled() -> Bool {
        let query = KeychainQuery(compilation: compilation,
                                      accountPath: \.keychain.account.widget)
        do {
            let passwordObject = try KeychainWrapper().fetch(query: query)
            if let object = passwordObject, let data = object as? NSNumber {
                return data.boolValue
            }
        } catch {
            return false
        }
        return false
    }
}
