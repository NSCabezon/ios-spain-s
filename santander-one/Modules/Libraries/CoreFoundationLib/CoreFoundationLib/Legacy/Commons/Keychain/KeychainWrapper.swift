import Foundation

public final class KeychainWrapper {
    
    public init() {}
    
    public func save(query: KeychainQuery) throws {
        if try KeychainOperations.exist(query: query) {
            try KeychainOperations.update(query: query)
        } else {
            try KeychainOperations.add(query: query)
        }
    }
    
    public func fetch(query: KeychainQuery) throws -> NSCoding? {
        guard try KeychainOperations.exist(query: query)
        else { throw KeychainErrors.itemNotFoundError }
        let data = try KeychainOperations.get(query: query)
        return query.unarchiveData(data)
    }
    
    public func fetch<T: AnyObject>(query: KeychainQuery, className: String?) -> T? {
        if let className = className {
            NSKeyedUnarchiver.setClass(T.self, forClassName: className)
        }
        let resp = try? fetch(query: query)
        return resp as? T
    }
    
    public func delete(query: KeychainQuery) throws {
        guard try KeychainOperations.exist(query: query)
        else { throw KeychainErrors.itemNotFoundError }
        try KeychainOperations.remove(query: query)
    }
}
