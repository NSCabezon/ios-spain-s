import Foundation
import CoreFoundationLib
import SAMKeychain
import ESCommons

class SaveTokenPushUseCase: UseCase<SaveTokenPushUseCaseInput, Void, StringErrorOutput> {
    
    private let compilation: CompilationProtocol
    
    init(dependenciesResolver: DependenciesResolver) {
        self.compilation = dependenciesResolver.resolve(for: CompilationProtocol.self)
    }
    
    override func executeUseCase(requestValues: SaveTokenPushUseCaseInput) throws -> UseCaseResponse<Void, StringErrorOutput> {
        let query = SAMKeychainQuery()
        query.account = compilation.keychain.account.tokenPush
        query.service = compilation.keychain.service
        query.accessGroup = compilation.keychain.sharedTokenAccessGroup
        query.passwordObject = requestValues.token as NSCoding
        do {
            try query.save()
            return .ok()
        } catch {
            return .error(StringErrorOutput(nil))
        }
    }
}

struct SaveTokenPushUseCaseInput {
    let token: Data
}
