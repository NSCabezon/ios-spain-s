//
//  DataRepositoryPolicy.swift
//  iOS Base
//
//  Created by Toni Moreno on 6/11/17.
//  Copyright © 2017 Toni. All rights reserved.
//

import Foundation

public class DataRepositoryPolicy: Codable {

    public static func createVersionPolicy() -> DataRepositoryPolicy {
        return DataRepositoryPolicy(StoragePolicyType.createHybridType(), true, nil)
    }

    public static func createStandardPolicy() -> DataRepositoryPolicy {
        return DataRepositoryPolicy(StoragePolicyType.createHybridType(), false, nil)
    }
    
    public static func createPersistentPolicy() -> DataRepositoryPolicy {
        return DataRepositoryPolicy(StoragePolicyType.createPersistentType(), false, nil)
    }
    
    public static func createVolatilePolicy() -> DataRepositoryPolicy {
        return DataRepositoryPolicy(StoragePolicyType.createVolatileType(), false, nil)
    }

    private var storagePolicyType: StoragePolicyType
    private var appInfo: VersionInfoDTO?
    private var cachePolicy: CachePolicy?
    private var resetDifferentVersion: Bool

    private init(_ storagePolicyType: StoragePolicyType, _  resetDifferentVersion: Bool, _ cachePolicy: CachePolicy?) {
        self.storagePolicyType = storagePolicyType
        self.resetDifferentVersion = resetDifferentVersion
        self.cachePolicy = cachePolicy
    }

    func getStoragePolicyType() -> StoragePolicyType {
        return storagePolicyType
    }

    func isValid() -> Bool {
        if cachePolicy != nil {
            return cachePolicy!.isValid()
        }
        return true
    }

    func setAppInfo(appInfo: VersionInfoDTO) {
        self.appInfo = appInfo
    }

    func isSameVersion(_ appInfo: VersionInfoDTO) -> Bool {
        if (self.appInfo != nil && resetDifferentVersion) {
            return self.appInfo == appInfo
        }
        return true
    }
}
