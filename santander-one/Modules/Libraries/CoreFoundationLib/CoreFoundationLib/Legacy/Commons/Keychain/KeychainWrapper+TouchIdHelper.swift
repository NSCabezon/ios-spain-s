import Foundation

public extension KeychainWrapper {
    func touchIdData(compilation: CompilationProtocol) -> TouchIdData? {
        NSKeyedArchiver.setClassName("TouchIdData", for: TouchIdData.self)
        let query = KeychainQuery(compilation: compilation,
                                  accountPath: \.keychain.account.touchId)
        return fetch(query: query,
                     className: "TouchIdData")
    }
    
    func saveTouchIdData(_ touchIdData: TouchIdData, compilation: CompilationProtocol) throws {
        NSKeyedArchiver.setClassName("TouchIdData", for: TouchIdData.self)
        let query = KeychainQuery(compilation: compilation,
                                  accountPath: \.keychain.account.touchId,
                                  data: touchIdData)
        try save(query: query)
    }
    
    func deleteTouchIdData(compilation: CompilationProtocol) throws {
        NSKeyedArchiver.setClassName("TouchIdData", for: TouchIdData.self)
        let query = KeychainQuery(compilation: compilation,
                                  accountPath: \.keychain.account.touchId)
        try delete(query: query)
    }
}
