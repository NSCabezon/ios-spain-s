//
//  Observable+Combine.swift
//  RxCombine
//
//  Created by Shai Mishali on 11/06/2019.
//  Copyright © 2019 Combine Community. All rights reserved.
//


import OpenCombine
import RxSwift


public extension ObservableConvertibleType {
    /// An `AnyPublisher` of the underlying Observable's Element type
    /// so the Observable pushes events to the Publisher.
    var publisher: AnyPublisher<Element, Swift.Error> {
        RxPublisher(upstream: self).eraseToAnyPublisher()
    }
    
    /// Returns a `AnyPublisher` of the underlying Observable's Element type
    /// so the Observable pushes events to the Publisher.
    ///
    /// - returns: AnyPublisher of the underlying Observable's Element type.
    /// - note: This is an alias for the `publisher` property.
    func asPublisher() -> AnyPublisher<Element, Swift.Error> {
        publisher
    }
}

/// A Publisher pushing RxSwift events to a Downstream Combine subscriber.

public class RxPublisher<Upstream: ObservableConvertibleType>: Publisher {
    public typealias Output = Upstream.Element
    public typealias Failure = Swift.Error

    private let upstream: Upstream

    init(upstream: Upstream) {
        self.upstream = upstream
    }

    public func receive<S: Subscriber>(subscriber: S) where Failure == S.Failure, Output == S.Input {
        subscriber.receive(subscription: RxSubscription(upstream: upstream,
                                                        downstream: subscriber))
    }
}

