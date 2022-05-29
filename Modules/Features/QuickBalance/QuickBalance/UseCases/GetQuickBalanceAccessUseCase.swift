import CoreFoundationLib
import ESCommons

final class GetQuickBalanceAccessUseCase: UseCase<Void, GetQuickBalanceAccessOkOutput, StringErrorOutput> {
    private let compilation: SpainCompilationProtocol
    
    init(dependenciesResolver: DependenciesResolver) {
        self.compilation = dependenciesResolver.resolve()
    }
    
    override public func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetQuickBalanceAccessOkOutput, StringErrorOutput> {
        let query = KeychainQuery(service: compilation.service,
                                      account: compilation.quickbalance,
                                      accessGroup: compilation.sharedTokenAccessGroup,
                                      data: NSNumber(value: true))
        do {
            let result = try KeychainWrapper().fetch(query: query) as? NSNumber.BooleanLiteralType ?? false
            return .ok(GetQuickBalanceAccessOkOutput(isKeychainQuickBalanceEnabled: result))
        } catch {
            return .error(StringErrorOutput(nil))
        }
    }
}

struct GetQuickBalanceAccessOkOutput {
    let isKeychainQuickBalanceEnabled: Bool
}
