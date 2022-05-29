//
//  MemoryDataSource.swift
//  iOS Base
//
//  Created by Toni Moreno on 6/11/17.
//  Copyright © 2017 Toni. All rights reserved.
//

import Foundation

public class MemoryDataSource: DataSource {

    private var memoryPersistenceArrayMap = ThreadSafeProperty([String: Any]())

    public init() {}
    
    public func getType() -> Int {
        return StoragePolicyType.VOLATILE_STORAGE
    }

    public func store<T>(dataWrapper: DataWrapper<T>) {
        memoryPersistenceArrayMap.value[dataWrapper.getkey()] = dataWrapper
    }

    public func get<T>(key: String, type: T.Type) -> DataWrapper<T>? {
        return memoryPersistenceArrayMap.value[key] as? DataWrapper<T>
    }

    public func remove(key: String) {
        memoryPersistenceArrayMap.value[key] = nil
    }

    public func clear() {
        memoryPersistenceArrayMap.value.removeAll()
    }
}

