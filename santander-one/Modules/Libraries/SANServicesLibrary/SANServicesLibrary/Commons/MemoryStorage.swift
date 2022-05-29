//
//  MemoryStorage.swift
//  SANServicesLibrary
//
//  Created by José Carlos Estela Anguita on 12/5/21.
//

import Foundation

final public class MemoryStorage: Storage {
    
    var storedData: [String: Any] = [:]
    
    public init() { }
    
    public func store<Data>(_ data: Data) {
        let anyData = data as? Any
        let key = String(describing: Data.self) as String
        self.storedData[key] = anyData
    }
    
    public func store<Data>(_ data: Data, type: Data.Type) {
        let anyData = data as? Any
        let key = String(describing: type) as String
        self.storedData[key] = anyData
    }
    
    public func store<Data>(_ data: Data, id: String) {
        let anyData = data as AnyObject
        self.storedData[id] = anyData
    }
    
    public func get<Data>() -> Data? {
        return self.get(Data.self)
    }
    
    public func get<Data>(_ type: Data.Type) -> Data? {
        let key = String(describing: type) as String
        return self.storedData[key] as? Data
    }
    
    public func get<Data>(id: String) -> Data? {
        return self.storedData[id] as? Data
    }
    
    public func clean() {
        self.storedData.removeAll()
    }
}
