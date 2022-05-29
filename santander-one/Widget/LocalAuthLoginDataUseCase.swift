import CoreFoundationLib
import SAMKeychain
import RetailLegacy

class LocalAuthLoginDataUseCase<Input, OkOutput, ErrorOutput: StringErrorOutput>: UseCase<Input, OkOutput, ErrorOutput> {
    
    private let compilation = CompilationAdapter.shared
    
    func getLocalAuthData(requestValues: Input) -> TouchIdData? {
        return SAMKeychainQuery().getTouchIdData(compilation)
    }
    
    func getLocalWidgetEnabled() -> Bool {
        let query = SAMKeychainQuery()
        query.account = Compilation.Keychain.Account.widget
        query.service = Compilation.Keychain.service
        query.accessGroup = Compilation.Keychain.sharedTokenAccessGroup
        do {
            try query.fetch()
            let passwordObject = query.passwordObject
            if let object = passwordObject, let data = object as? NSNumber {
                return data.boolValue
            }
        } catch {
            return false
        }
        return false
    }
}
