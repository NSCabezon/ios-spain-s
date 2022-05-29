import CoreFoundationLib
import ESCommons

final class ActivateQuickBalanceAccessUseCase: UseCase<Void, Void, StringErrorOutput> {
    private let compilation: SpainCompilationProtocol
    
    init(dependenciesResolver: DependenciesResolver) {
        self.compilation = dependenciesResolver.resolve()
    }
    
    override public func executeUseCase(requestValues: Void) throws -> UseCaseResponse<Void, StringErrorOutput> {
        let query = KeychainQuery(service: compilation.service,
                                      account: compilation.quickbalance,
                                      accessGroup: compilation.sharedTokenAccessGroup,
                                      data: NSNumber(value: true))
        do {
            try KeychainWrapper().save(query: query)
            return UseCaseResponse.ok()
        } catch {
            return .error(StringErrorOutput(nil))
        }
    }
}
