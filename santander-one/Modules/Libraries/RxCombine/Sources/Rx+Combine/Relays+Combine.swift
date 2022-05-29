//
//  Relays+Combine.swift
//  RxCombine
//
//  Created by Shai Mishali on 11/06/2019.
//  Copyright © 2019 Combine Community. All rights reserved.
//


import OpenCombine
import RxSwift
import RxRelay

// MARK: - Behavior Relay as Publisher

extension BehaviorRelay {
    /// An `AnyPublisher` of the underlying Relay's Element type
    /// so the relay pushes events to the Publisher.
    var publisher: AnyPublisher<Element, Never> {
        RxPublisher(upstream: self).assertNoFailure().eraseToAnyPublisher()
    }

    /// An `AnyPublisher` of the underlying Relay's Element type
    /// so the relay pushes events to the Publisher.
    ///
    /// - returns: AnyPublisher of the underlying Relay's Element type.
    /// - note: This is an alias for the `publisher` property.
    func asPublisher() -> AnyPublisher<Element, Never> {
        publisher
    }
}

// MARK: - Publish Relay as Publisher

extension PublishRelay {
    /// An `AnyPublisher` of the underlying Relay's Element type
    /// so the relay pushes events to the Publisher.
    var publisher: AnyPublisher<Element, Never> {
        RxPublisher(upstream: self).assertNoFailure().eraseToAnyPublisher()
    }

    /// An `AnyPublisher` of the underlying Relay's Element type
    /// so the relay pushes events to the Publisher.
    ///
    /// - returns: AnyPublisher of the underlying Relay's Element type.
    /// - note: This is an alias for the `publisher` property.
    func asPublisher() -> AnyPublisher<Element, Never> {
        publisher
    }
}

