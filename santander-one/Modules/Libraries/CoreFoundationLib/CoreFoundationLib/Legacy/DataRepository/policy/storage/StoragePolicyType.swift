//
//  StoragePolicyType.swift
//  iOS Base
//
//  Created by Toni Moreno on 6/11/17.
//  Copyright © 2017 Toni. All rights reserved.
//

import Foundation

public class StoragePolicyType: Codable {

    static let PERSISTENT_STORAGE: Int = 0
    static let VOLATILE_STORAGE: Int = 1
    static let HYBRID_STORAGE: Int = 2

    private var type: Int

    static func createPersistentType() -> StoragePolicyType {
        return StoragePolicyType(PERSISTENT_STORAGE)
    }
    
    static func createVolatileType() -> StoragePolicyType {
        return StoragePolicyType(VOLATILE_STORAGE)
    }

    static func createHybridType() -> StoragePolicyType {
        return StoragePolicyType(HYBRID_STORAGE)
    }

    init(_ type: Int) {
        self.type = type
    }

    func getType() -> Int {
        return type
    }

}
