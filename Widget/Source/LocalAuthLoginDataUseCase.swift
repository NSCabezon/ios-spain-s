import CoreFoundationLib
import RetailLegacy

class LocalAuthLoginDataUseCase<Input, OkOutput, ErrorOutput: StringErrorOutput>: UseCase<Input, OkOutput, ErrorOutput> {
    
    let compilation = Compilation()
    
    func getLocalAuthData(requestValues: Input) -> TouchIdData? {
        return KeychainWrapper().touchIdData(compilation: compilation)
    }
    
    func getLocalWidgetEnabled() -> Bool {
        let query = KeychainQuery(service: Compilation.Keychain.service,
                                      account: Compilation.Keychain.Account.widget,
                                      accessGroup: Compilation.Keychain.sharedTokenAccessGroup)
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
