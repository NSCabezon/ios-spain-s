//
// Created by Guillermo on 25/1/18.
// Copyright (c) 2018 Ciber. All rights reserved.
//

import Foundation

public class HybridDataSource: DataSource {
    private var memoryDataSource : MemoryDataSource
    private var udDataSource : UDDataSource

    public init(memoryDataSource: MemoryDataSource, udDataSource: UDDataSource) {
        self.memoryDataSource = memoryDataSource
        self.udDataSource = udDataSource
    }

    public func getType() -> Int {
        return StoragePolicyType.HYBRID_STORAGE
    }

    public func store<T>(dataWrapper: DataWrapper<T>) {
        memoryDataSource.store(dataWrapper: dataWrapper)
        udDataSource.store(dataWrapper: dataWrapper)
    }

    public func get<T>(key: String, type: T.Type) -> DataWrapper<T>? {
        if let data = memoryDataSource.get(key: key, type: type) {
            return data
        }
        if let data = udDataSource.get(key: key, type: type) {
            memoryDataSource.store(dataWrapper: data)
            return data
        }

        return nil
    }

    public func remove(key: String) {
        memoryDataSource.remove(key: key)
        udDataSource.remove(key: key)
    }

    public func clear() {
        memoryDataSource.clear()
        udDataSource.clear()
    }
}
