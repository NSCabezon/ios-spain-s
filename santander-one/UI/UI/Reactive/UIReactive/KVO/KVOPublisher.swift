//
//  KVOPublisher.swift
//  OpenKit
//
//  Created by Juan Carlos López Robles on 3/16/22.
//

import Foundation
import OpenCombine
import OpenCombineDispatch

/// Publish property value changes specifying a KeyPath.
///
/// Use `publisher(keyPath:_:)` to take track of an object property changes using KeyPath
///
/// In the example below, the `publisher(keyPath:_:)` publisher is used to track the changes of `UILabel.text` property, publishing the
/// new value each time it change
///
///     let label = UILabel()
///     cancellable = label.publisher(keyPath: \.text)
///         .sink { newTextValue in
///             print(newTextValue)
///         }
///         
///     // change the property
///     label.text = "Assigned text"
///
///     // Prints: "nil"
///     // Prints: "Assigned text"
///
/// - Parameter keyPath: The `KeyPath` property to  republish.
/// - Parameter options: The `NSKeyValueObservingOptions` witch are`[.initial, .new]`by default .
/// - Returns: A publisher that publishes each time the `KeyPath` change
///

struct KVOPublisher<Object, Value>: Publisher where Object: NSObject {
    public typealias Output = Value
    public typealias Failure = Never
    private let object: Object
    private let keyPath: KeyPath<Object, Value>
    private let options: NSKeyValueObservingOptions

    public init(object: Object, keyPath: KeyPath<Object, Value>, options: NSKeyValueObservingOptions) {
        self.object = object
        self.keyPath = keyPath
        self.options = options
    }
    
    public func receive<S>(subscriber: S) where S: Subscriber, Never == S.Failure, Output == S.Input {
        let subscription = Subscription(subscriber: subscriber, object: object, keyPath: keyPath, options: options)
        subscriber.receive(subscription: subscription)
    }
}

extension KVOPublisher: Equatable {
    public static func == (lhs: KVOPublisher, rhs: KVOPublisher) -> Bool {
        return lhs.object === rhs.object
            && lhs.keyPath == rhs.keyPath
            && lhs.options == rhs.options
    }
}

private extension KVOPublisher {
    final class Subscription<S, Object, Value>: OpenCombine.Subscription where S: Subscriber, S.Input == Value, Object: NSObject {
        private var subscriber: S?
        private var keyValueObservation: NSKeyValueObservation?
        private let lock = NSRecursiveLock()
        private var demand: Subscribers.Demand
        private var initialValue: Value?
        
        init(subscriber: S, object: Object, keyPath: KeyPath<Object, Value>, options: NSKeyValueObservingOptions) {
            self.subscriber = subscriber
            self.demand = .none
            self.keyValueObservation = object.observe(
                keyPath, options: options) { [weak self] obj, _ in
                    guard let self = self else { return }
                    self.lock.lock()
                    if self.demand > .none, let subscriber = self.subscriber {
                        self.demand += subscriber.receive(obj[keyPath: keyPath])
                        self.lock.unlock()
                    } else {
                        if options.contains(.initial) {
                            self.initialValue = obj[keyPath: keyPath]
                        }
                        self.lock.unlock()
                    }
                }
        }
        
        func request(_ demand: Subscribers.Demand) {
            self.lock.lock()
            self.demand += demand
            if demand > .none,
               let initial = self.initialValue,
               let subscriber = self.subscriber {
                self.demand -= 1
                self.initialValue = nil
                self.demand += subscriber.receive(initial)
            } else {
                self.demand -= 1
                self.initialValue = nil
            }
            self.lock.unlock()
        }
        
        func cancel() {
            lock.lock()
            let kvo = keyValueObservation
            subscriber = nil
            keyValueObservation = nil
            kvo?.invalidate()
            lock.unlock()
        }
    }
}
