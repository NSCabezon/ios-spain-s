import Foundation

public struct Locker {
    public static func read(stringFromService service: String, andAccount account: String) -> String? {
        return Keychain.load(service, account)?.UTF8String
    }
    
    public static func read(dataFromService service: String, andAccount account: String) -> Data? {
        return Keychain.load(service, account)
    }
    
    public static func delete(service: String, account: String) -> Bool {
        return Keychain.delete(service: service, account: account)
    }
    
    public static func save(_ data: Data, inService service: String, andAccount account: String) -> Bool {
        return Keychain.save(service, account: account, data: data)
    }
    
    public static func save(_ string: String, inService service: String, andAccount account: String) -> Bool {
        return Keychain.save(service, account: account, string: string)
    }
    
    public static var clear : Bool {
        return Keychain.clear
    }
}
