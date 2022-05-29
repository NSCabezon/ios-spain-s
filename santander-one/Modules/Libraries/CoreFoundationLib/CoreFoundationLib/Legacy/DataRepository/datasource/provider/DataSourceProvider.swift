//
//  DataSourceProvider.swift
//  iOS Base
//
//  Created by Toni Moreno on 6/11/17.
//  Copyright © 2017 Toni. All rights reserved.
//

import Foundation

public protocol DataSourceProvider {
    func get(storagePolicyType: StoragePolicyType) -> DataSource
}
