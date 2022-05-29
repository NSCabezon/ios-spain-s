import Foundation
import CoreFoundationLib

class RemoveTokenPushUseCase: UseCase<Void, Void, StringErrorOutput> {
    private let compilation: CompilationProtocol
    
    init(dependenciesResolver: DependenciesResolver) {
        self.compilation = dependenciesResolver.resolve(for: CompilationProtocol.self)
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<Void, StringErrorOutput> {
        let query = KeychainQuery(compilation: compilation,
                                      accountPath: \.keychain.account.tokenPush)
        do {
            try KeychainWrapper().delete(query: query)
            return .ok()
        } catch {
            return .error(StringErrorOutput(nil))
        }
    }
}
