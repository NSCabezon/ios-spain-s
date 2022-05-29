//
//  DataBindable.swift
//  Commons
//
//  Created by Juan Carlos López Robles on 11/11/21.
//

import Foundation
// MARK: - Binder

public protocol DataBindable {
    typealias Binding<Value> = AnyBinding<Self, Value>
    typealias BindingOptional<Value: ExpressibleByNilLiteral> = AnyBindingOptional<Self, Value>
    var dataBinding: DataBinding { get }
}
