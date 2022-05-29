//
//  DataRepositoryImpl.swift
//  iOS Base
//
//  Created by Toni Moreno on 6/11/17.
//  Copyright © 2017 Toni. All rights reserved.
//

import Foundation

public class DataRepositoryImpl: DataRepository {

    private let appInfo: VersionInfoDTO
    private let dataSourceProvider: DataSourceProvider
    
    public init(dataSourceProvider: DataSourceProvider, appInfo: VersionInfoDTO) {
        self.appInfo = appInfo
        self.dataSourceProvider = dataSourceProvider
    }

    public func store<T>(_ t: T) where T: Codable {
        store(t, String(describing: type(of: t)))
    }
    
    public func store<T>(_ t: T, _ dataRepositoryPolicy: DataRepositoryPolicy) where T: Codable {
        store(t, String(describing: type(of: t)), dataRepositoryPolicy)
    }

    public func store<T>(_ t: T, _ key: String) where T: Codable {
        store(t, key, getDataRepositoryPolicy())
    }

    public func store<T>(_ t: T, _ key: String, _ dataRepositoryPolicy: DataRepositoryPolicy) where T: Codable {
        dataRepositoryPolicy.setAppInfo(appInfo: appInfo)
        dataSourceProvider.get(storagePolicyType: dataRepositoryPolicy.getStoragePolicyType()).store(dataWrapper: DataWrapper.createDataWrapper(t, key, dataRepositoryPolicy))
    }
    
    public func get<T>(_ type: T.Type) -> T? where T: Codable {
        return get(type, String(describing: type.self))
    }
    
    public func get<T>(_ type: T.Type, _ dataRepositoryPolicy: DataRepositoryPolicy) -> T? where T: Codable {
        return get(type, String(describing: type.self), dataRepositoryPolicy)
    }

    public func get<T>(_ type: T.Type, _ key: String) -> T? where T: Codable {
        return get(type, key, getDataRepositoryPolicy())
    }

    public func get<T>(_ type: T.Type, _ key: String, _ dataRepositoryPolicy: DataRepositoryPolicy) -> T? where T: Decodable, T: Encodable {
        if let dataWrapper = dataSourceProvider.get(storagePolicyType: dataRepositoryPolicy.getStoragePolicyType()).get(key: key, type: type) {
            return dataWrapper.get(appInfo: appInfo)
        }
        return nil
    }

    public func remove<T>(_ type: T.Type) {
        remove(type, String(describing: type.self))
    }
    
    public func remove<T>(_ type: T.Type, _ dataRepositoryPolicy: DataRepositoryPolicy) {
        remove(type, String(describing: type.self), dataRepositoryPolicy)
    }

    public func remove<T>(_ type: T.Type, _ key: String) {
        remove(type, key, getDataRepositoryPolicy())
    }

    public func remove<T>(_ type: T.Type, _ key: String, _ dataRepositoryPolicy: DataRepositoryPolicy) {
        dataSourceProvider.get(storagePolicyType: dataRepositoryPolicy.getStoragePolicyType()).remove(key: key)
    }

    private func getDataRepositoryPolicy() -> DataRepositoryPolicy {
        let dataRepositoryPolicy = DataRepositoryPolicy.createVersionPolicy();
        dataRepositoryPolicy.setAppInfo(appInfo: appInfo);
        return dataRepositoryPolicy;
    }

}
