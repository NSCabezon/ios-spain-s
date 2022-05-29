//
//  NSObject+Publisher+Combine.swift
//  OpenKit
//
//  Created by Juan Carlos López Robles on 3/16/22.
//

import Foundation
import OpenCombine
import UIKit

///A protocol that allow you to use `publisher(keyPath:_:)` on each class that implemented it.
///The class should be anherientece from `NSObject` like `UIView`

public protocol KVOPublisherObservable {
    associatedtype KVOObject: NSObject
    func publisher<Value>(keyPath: KeyPath<KVOObject, Value>, options: NSKeyValueObservingOptions) -> AnyPublisher<Value, Never>
}

public extension KVOPublisherObservable where Self: NSObject {
    typealias KVOObject = Self
    func publisher<Value>(keyPath: KeyPath<Self, Value>, options: NSKeyValueObservingOptions = [.initial, .new]) -> AnyPublisher<Value, Never> {
        return KVOPublisher<Self, Value>(object: self, keyPath: keyPath, options: options)
            .eraseToAnyPublisher()
    }
}

extension UIView: KVOPublisherObservable {}
