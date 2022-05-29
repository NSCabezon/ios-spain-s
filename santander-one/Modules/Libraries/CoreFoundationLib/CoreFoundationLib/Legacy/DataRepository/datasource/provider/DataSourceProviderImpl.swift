//
//  DataSourceProviderImpl.swift
//  iOS Base
//
//  Created by Toni Moreno on 6/11/17.
//  Copyright © 2017 Toni. All rights reserved.
//

import Foundation

public class DataSourceProviderImpl: DataSourceProvider {

    private var dataSourceArrayMap: [Int: DataSource] = [:]
    private var defaultDataSource: DataSource

    public init(defaultDataSource: DataSource, dataSources: [DataSource]) {
        self.defaultDataSource = defaultDataSource

        for dataSource in dataSources {
            dataSourceArrayMap[dataSource.getType()] = dataSource
        }
    }

    public func get(storagePolicyType: StoragePolicyType) -> DataSource {
        if let dataSource = dataSourceArrayMap[storagePolicyType.getType()] {
            return dataSource
        }
        return defaultDataSource
    }
}
