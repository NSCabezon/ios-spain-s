//
//  DataSource.swift
//  iOS Base
//
//  Created by Toni Moreno on 6/11/17.
//  Copyright © 2017 Toni. All rights reserved.
//

import Foundation

public protocol DataSource {

    func getType() -> Int

    func store<T>(dataWrapper: DataWrapper<T>)

    func get<T>(key: String, type: T.Type) -> DataWrapper<T>?

    func remove(key: String)

    func clear()
}
