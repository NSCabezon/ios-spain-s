//
//  Publishers.CombineLates.swift
//  Commons
//
//  Created by Juan Carlos López Robles on 11/23/21.
//

import Foundation
import OpenCombine
import RxSwift

extension OpenCombine.Publishers {

    /// A publisher that receives and combines the latest elements from two publishers.
    public struct CombineLatest<A, B> : Publisher where A : Publisher, B : Publisher, A.Failure == B.Failure {

        /// The kind of values published by this publisher.
        public typealias Output = (A.Output, B.Output)

        /// The kind of errors this publisher might publish.
        ///
        /// Use `Never` if this `Publisher` does not publish errors.
        public typealias Failure = A.Failure

        public let a: A

        public let b: B

        public init(_ a: A, _ b: B) {
            self.a = a
            self.b = b
        }

        /// Attaches the specified subscriber to this publisher.
        ///
        /// Implementations of ``Publisher`` must implement this method.
        ///
        /// The provided implementation of ``Publisher/subscribe(_:)-4u8kn``calls this method.
        ///
        /// - Parameter subscriber: The subscriber to attach to this ``Publisher``, after which it can receive values.
        public func receive<S>(subscriber: S) where S : Subscriber, B.Failure == S.Failure, S.Input == Publishers.CombineLatest<A, B>.Output {
            Observable.combineLatest(
                a.asObservable(),
                b.asObservable()
            ).asPublisher()
            // Force cast since Observable error is not a generic, but it will be always a S.Failure
            .mapError({ $0 as! S.Failure})
            .subscribe(subscriber)
        }
    }
}

extension OpenCombine.Publisher {

    /// Subscribes to an additional publisher and publishes a tuple upon receiving output from either publisher.
    ///
    /// Use ``Publisher/combineLatest(_:)`` when you want the downstream subscriber to receive a tuple of the most-recent element from multiple publishers when any of them emit a value. To pair elements from multiple publishers, use ``Publisher/zip(_:)`` instead. To receive just the most-recent element from multiple publishers rather than tuples, use ``Publisher/merge(with:)-7qt71``.
    ///
    /// > Tip: The combined publisher doesn't produce elements until each of its upstream publishers publishes at least one element.
    ///
    /// The combined publisher passes through any requests to *all* upstream publishers. However, it still obeys the demand-fulfilling rule of only sending the request amount downstream. If the demand isn’t ``Subscribers/Demand/unlimited``, it drops values from upstream publishers. It implements this by using a buffer size of 1 for each upstream, and holds the most-recent value in each buffer.
    ///
    /// In this example, ``PassthroughSubject`` `pub1` and also `pub2` emit values; as ``Publisher/combineLatest(_:)`` receives input from either upstream publisher, it combines the latest value from each publisher into a tuple and publishes it.
    ///
    ///     let pub1 = PassthroughSubject<Int, Never>()
    ///     let pub2 = PassthroughSubject<Int, Never>()
    ///
    ///     cancellable = pub1
    ///         .combineLatest(pub2)
    ///         .sink { print("Result: \($0).") }
    ///
    ///     pub1.send(1)
    ///     pub1.send(2)
    ///     pub2.send(2)
    ///     pub1.send(3)
    ///     pub1.send(45)
    ///     pub2.send(22)
    ///
    ///     // Prints:
    ///     //    Result: (2, 2).    // pub1 latest = 2, pub2 latest = 2
    ///     //    Result: (3, 2).    // pub1 latest = 3, pub2 latest = 2
    ///     //    Result: (45, 2).   // pub1 latest = 45, pub2 latest = 2
    ///     //    Result: (45, 22).  // pub1 latest = 45, pub2 latest = 22
    ///
    /// When all upstream publishers finish, this publisher finishes. If an upstream publisher never publishes a value, this publisher never finishes.
    ///
    /// - Parameter other: Another publisher to combine with this one.
    /// - Returns: A publisher that receives and combines elements from this and another publisher.
    public func combineLatest<P>(_ other: P) -> Publishers.CombineLatest<Self, P> where P : Publisher, Self.Failure == P.Failure {
        return OpenCombine.Publishers.CombineLatest(self, other)
    }

    /// Subscribes to an additional publisher and invokes a closure upon receiving output from either publisher.
    ///
    /// Use `combineLatest<P,T>(_:)` to combine the current and one additional publisher and transform them using a closure you specify to publish a new value to the downstream.
    ///
    /// > Tip: The combined publisher doesn't produce elements until each of its upstream publishers publishes at least one element.
    ///
    /// The combined publisher passes through any requests to *all* upstream publishers. However, it still obeys the demand-fulfilling rule of only sending the request amount downstream. If the demand isn’t `.unlimited`, it drops values from upstream publishers. It implements this by using a buffer size of 1 for each upstream, and holds the most-recent value in each buffer.
    ///
    /// In the example below, `combineLatest()` receives the most-recent values published by the two publishers, it multiplies them together, and republishes the result:
    ///
    ///     let pub1 = PassthroughSubject<Int, Never>()
    ///     let pub2 = PassthroughSubject<Int, Never>()
    ///     cancellable = pub1
    ///         .combineLatest(pub2) { (first, second) in
    ///             return first * second
    ///         }
    ///         .sink { print("Result: \($0).") }
    ///
    ///     pub1.send(1)
    ///     pub1.send(2)
    ///     pub2.send(2)
    ///     pub1.send(9)
    ///     pub1.send(3)
    ///     pub2.send(12)
    ///     pub1.send(13)
    ///     //
    ///     // Prints:
    ///     //Result: 4.    (pub1 latest = 2, pub2 latest = 2)
    ///     //Result: 18.   (pub1 latest = 9, pub2 latest = 2)
    ///     //Result: 6.    (pub1 latest = 3, pub2 latest = 2)
    ///     //Result: 36.   (pub1 latest = 3, pub2 latest = 12)
    ///     //Result: 156.  (pub1 latest = 13, pub2 latest = 12)
    ///
    /// All upstream publishers need to finish for this publisher to finish. If an upstream publisher never publishes a value, this publisher never finishes.
    /// If any of the combined publishers terminates with a failure, this publisher also fails.
    ///
    /// - Parameters:
    ///   - other: Another publisher to combine with this one.
    ///   - transform: A closure that receives the most-recent value from each publisher and returns a new value to publish.
    /// - Returns: A publisher that receives and combines elements from this and another publisher.
    public func combineLatest<P, T>(_ other: P, _ transform: @escaping (Self.Output, P.Output) -> T) -> Publishers.Map<Publishers.CombineLatest<Self, P>, T> where P : Publisher, Self.Failure == P.Failure {
        return OpenCombine.Publishers.CombineLatest(self, other).map(transform)
    }
}
