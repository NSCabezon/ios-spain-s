import CoreFoundationLib
import ESCommons

final class DeleteQuickBalanceAccessUseCase: UseCase<Void, Void, StringErrorOutput> {
    private let compilation: SpainCompilationProtocol
    
    init(dependenciesResolver: DependenciesResolver) {
        self.compilation = dependenciesResolver.resolve()
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<Void, StringErrorOutput> {
        let query = KeychainQuery(service: compilation.service,
                                      account: compilation.quickbalance,
                                      accessGroup: compilation.sharedTokenAccessGroup)
        do {
            try KeychainWrapper().delete(query: query)
            return .ok()
        } catch {
            return .error(StringErrorOutput(nil))
        }
    }
}
