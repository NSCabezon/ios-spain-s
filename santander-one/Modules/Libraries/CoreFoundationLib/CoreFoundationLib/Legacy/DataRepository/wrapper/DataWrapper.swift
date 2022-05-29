//
//  DataWrapper.swift
//  iOS Base
//
//  Created by Toni Moreno on 6/11/17.
//  Copyright © 2017 Toni. All rights reserved.
//

import Foundation

public class DataWrapper<T>: Codable where T: Codable {

    public static func createDataWrapper(_ t: T, _ key: String, _ dataRepositoryPolicy: DataRepositoryPolicy) -> DataWrapper<T> {
        return DataWrapper(key, t, dataRepositoryPolicy)
    }

    public static func createDataWrapper(_ t: T, _ dataRepositoryPolicy: DataRepositoryPolicy) -> DataWrapper<T> {
        return DataWrapper(String(describing: type(of: t)), t, dataRepositoryPolicy)
    }
    
    private var dataRepositoryPolicy: DataRepositoryPolicy
    private var key: String
    private var t: T

    private init(_ key: String, _ t: T, _ dataRepositoryPolicy: DataRepositoryPolicy) {
        self.key = key
        self.dataRepositoryPolicy = dataRepositoryPolicy
        self.t = t
    }

    public func getkey() -> String {
        return key
    }

    public func get(appInfo: VersionInfoDTO) -> T? {
        if dataRepositoryPolicy.isValid() && dataRepositoryPolicy.isSameVersion(appInfo) {
            return t
        }
        return nil
    }

}
