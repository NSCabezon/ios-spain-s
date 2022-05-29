import Foundation
import CoreFoundationLib

class SaveTokenPushUseCase: UseCase<SaveTokenPushUseCaseInput, Void, StringErrorOutput> {
    
    private let compilation: CompilationProtocol
    
    init(dependenciesResolver: DependenciesResolver) {
        self.compilation = dependenciesResolver.resolve(for: CompilationProtocol.self)
    }
    
    override func executeUseCase(requestValues: SaveTokenPushUseCaseInput) throws -> UseCaseResponse<Void, StringErrorOutput> {
        let query = KeychainQuery(compilation: compilation,
                                      accountPath: \.keychain.account.tokenPush,
                                      data: requestValues.token as NSCoding)
        do {
            try KeychainWrapper().save(query: query)
            return .ok()
        } catch {
            return .error(StringErrorOutput(nil))
        }
    }
}

struct SaveTokenPushUseCaseInput {
    let token: Data
}
