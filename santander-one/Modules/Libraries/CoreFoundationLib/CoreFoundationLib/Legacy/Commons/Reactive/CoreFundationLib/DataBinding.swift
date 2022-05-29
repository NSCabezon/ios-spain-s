//
//  DataBinding.swift
//  Alamofire
//
//  Created by Juan Carlos López Robles on 11/16/21.
//

import Foundation

public protocol DataBinding {
    func get<T>() -> T?
    func set<T>(_ value: T)
    func contains<T>(_ type: T.Type) -> Bool
}
