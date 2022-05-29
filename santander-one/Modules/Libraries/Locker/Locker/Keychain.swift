import Foundation

struct Keychain {
    // MARK: - Keychain Save Query
    static func save(_ service: String, account: String, string: String) -> Bool {
        let query = Query { builder in
            builder.account = account
            builder.service = service
            builder.data = string.data
        }
        
        return query.save
    }
    
    static func save(_ service: String, account: String, data: Data) -> Bool {
        let query = Query { builder in
            builder.account = account
            builder.service = service
            builder.data = data
        }
        
        return query.save
    }
    
    // MARK: - Keychain Load Query
    static func load(_ service: String, _ account: String) -> Data? {
        return Query(service: service, account: account).load
    }
    
    // MARK: - Keychain Delete Query
    static func delete(service: String, account: String) -> Bool {
        let query = Query { builder in
            builder.account = account
            builder.service = service
        }
        
        return query.delete
    }
    
    // MARK: - Clean Keychain
    static var clear : Bool {
        return Query.clear
    }
}

internal extension Data {
    var UTF8String: String? {
        return NSString(data: self, encoding: String.Encoding.utf8.rawValue) as String?
    }
}

internal extension String {
    var data: Data? {
        return self.data(using: String.Encoding.utf8)
    }
}
