//
//  Bindable.swift
//  Commons
//
//  Created by Juan Carlos López Robles on 11/11/21.
//

import Foundation

public protocol Bindable {
    var dataBinding: DataBinding { get }
    func set<T>(_ value: T) -> Self
}

public extension Bindable {
   func set<T>(_ value: T) -> Self {
        dataBinding.set(value)
        return self
    }
}
