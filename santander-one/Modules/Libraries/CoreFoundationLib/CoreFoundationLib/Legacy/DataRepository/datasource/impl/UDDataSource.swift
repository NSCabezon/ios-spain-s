//
//  SPDataSource.swift
//  iOS Base
//
//  Created by Toni Moreno on 6/11/17.
//  Copyright © 2017 Toni. All rights reserved.
//

import Foundation

public enum UDDataSourceDomain {
    case standard
    case suite(name: String)
    
    var userDefaults: UserDefaults {
        let userDefaults: UserDefaults
        switch self {
        case .standard:
            userDefaults = UserDefaults.standard
        case .suite(let name):
            guard let suite = UserDefaults(suiteName: name) else {
                fatalError("A valid suite must be provided")
            }
            userDefaults = suite
        }
        return userDefaults
    }
    
    var name: String? {
        switch self {
        case .standard:
            return Bundle.main.bundleIdentifier
        case .suite(let name):
            return name
        }
    }
}

public class UDDataSource: DataSource {

    var LOG_TAG: String {
        return String(describing: type(of: self))
    }
    
    private let userDefaults: UserDefaults
    private let userDefaultsDomain: UDDataSourceDomain
    private var serializer: Serializer
    private var dataCipher: DataCipher

    public init(serializer: Serializer, appInfo: VersionInfoDTO, keychainService: KeychainService, domain: UDDataSourceDomain = .standard) {
        self.serializer = serializer
        self.userDefaultsDomain = domain
        self.userDefaults = domain.userDefaults
        self.dataCipher = DataCipher(keychainService: keychainService)
    }

    public func getType() -> Int {
        return StoragePolicyType.PERSISTENT_STORAGE
    }

    public func store<T>(dataWrapper: DataWrapper<T>) {
        let serialized = serializer.serialize(dataWrapper)
        putString(dataWrapper.getkey(), serialized)
    }

    public func get<T>(key: String, type: T.Type) -> DataWrapper<T>? {
        if let serialized = getString(key), !serialized.isEmpty {
            return serializer.deserializeWrapper(serialized, type)
        }
        return nil
    }

    public func remove(key: String) {
        DataLogger.v(LOG_TAG, "Removing in cache \(key)");
        userDefaults.removeObject(forKey: key)
    }

    public func clear() {
        guard let domain = userDefaultsDomain.name else {
            return
        }
        userDefaults.removePersistentDomain(forName: domain)
        userDefaults.synchronize()
    }


    private func putString(_ key: String, _ plainText: String?) {
        if let plainText = plainText {
            DataLogger.v(LOG_TAG, "Saving in cache \(plainText)")
            userDefaults.set(dataCipher.encryptAES(plainText), forKey: key)
            return
        }
        userDefaults.set(nil, forKey: key)
    }

    private func getString(_ key: String) -> String? {
        if let cipheredText = userDefaults.string(forKey: key) {
            let decipheredText  = dataCipher.decryptAES(cipheredText)
            DataLogger.v(LOG_TAG, "Retreiving from cache \(decipheredText)")
            return decipheredText
        }
        return nil
    }

}
