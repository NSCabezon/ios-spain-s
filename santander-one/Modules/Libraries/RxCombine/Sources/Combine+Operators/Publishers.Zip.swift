 //
//  OpenCombine+Zip.swift
//  Commons
//
//  Created by José Carlos Estela Anguita on 28/10/21.
//

import Foundation
import OpenCombine
import RxSwift

extension OpenCombine.Publishers {
    
    /// A publisher created by applying the zip function to two upstream publishers.
    public struct Zip<A, B> : Publisher where A : Publisher, B : Publisher, A.Failure == B.Failure {

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

        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where S : Subscriber, B.Failure == S.Failure, S.Input == (A.Output, B.Output) {
            Observable.zip(
                a.asObservable(),
                b.asObservable()
            )
            .asPublisher()
            .mapError({ $0 as! S.Failure }) // Force cast since Observable error is not a generic, but it will be always a S.Failure
            .subscribe(subscriber)
        }
    }
    
    /// A publisher created by applying the zip function to two upstream publishers.
    public struct Zip3<A, B, C> : Publisher where A : Publisher, B : Publisher, C: Publisher, A.Failure == B.Failure, B.Failure == C.Failure {

        /// The kind of values published by this publisher.
        public typealias Output = (A.Output, B.Output, C.Output)

        /// The kind of errors this publisher might publish.
        ///
        /// Use `Never` if this `Publisher` does not publish errors.
        public typealias Failure = A.Failure

        public let a: A
        public let b: B
        public let c: C

        public init(_ a: A, _ b: B, _ c: C) {
            self.a = a
            self.b = b
            self.c = c
        }

        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where S : Subscriber, B.Failure == S.Failure, S.Input == (A.Output, B.Output, C.Output) {
            Observable.zip(
                a.asObservable(),
                b.asObservable(),
                c.asObservable()
            )
            .asPublisher()
            .mapError({ $0 as! S.Failure }) // Force cast since Observable error is not a generic, but it will be always a S.Failure
            .subscribe(subscriber)
        }
    }
    
    
    /// A publisher created by applying the zip function to two upstream publishers.
    public struct Zip4<A, B, C, D> : Publisher where A : Publisher, B : Publisher, C: Publisher, D: Publisher, A.Failure == B.Failure, B.Failure == C.Failure, C.Failure == D.Failure {

        /// The kind of values published by this publisher.
        public typealias Output = (A.Output, B.Output, C.Output, D.Output)

        /// The kind of errors this publisher might publish.
        ///
        /// Use `Never` if this `Publisher` does not publish errors.
        public typealias Failure = A.Failure

        public let a: A
        public let b: B
        public let c: C
        public let d: D

        public init(_ a: A, _ b: B, _ c: C, _ d: D) {
            self.a = a
            self.b = b
            self.c = c
            self.d = d
        }

        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where S : Subscriber, B.Failure == S.Failure, S.Input == (A.Output, B.Output, C.Output, D.Output) {
            Observable.zip(
                a.asObservable(),
                b.asObservable(),
                c.asObservable(),
                d.asObservable()
            )
            .asPublisher()
            .mapError({ $0 as! S.Failure }) // Force cast since Observable error is not a generic, but it will be always a S.Failure
            .subscribe(subscriber)
        }
    }
}

extension OpenCombine.Publisher {

    /// Combine elements from another publisher and deliver pairs of elements as tuples.
    ///
    /// The returned publisher waits until both publishers have emitted an event, then delivers the oldest unconsumed event from each publisher together as a tuple to the subscriber.
    /// For example, if publisher `P1` emits elements `a` and `b`, and publisher `P2` emits event `c`, the zip publisher emits the tuple `(a, c)`. It won’t emit a tuple with event `b` until `P2` emits another event.
    /// If either upstream publisher finishes successfuly or fails with an error, the zipped publisher does the same.
    ///
    /// - Parameter other: Another publisher.
    /// - Returns: A publisher that emits pairs of elements from the upstream publishers as tuples.
    public func zip<P>(_ other: P) -> OpenCombine.Publishers.Zip<Self, P> where P : Publisher, Self.Failure == P.Failure {
        OpenCombine.Publishers.Zip(self, other)
    }

    /// Combine elements from another publisher and deliver a transformed output.
    ///
    /// The returned publisher waits until both publishers have emitted an event, then delivers the oldest unconsumed event from each publisher together as a tuple to the subscriber.
    /// For example, if publisher `P1` emits elements `a` and `b`, and publisher `P2` emits event `c`, the zip publisher emits the tuple `(a, c)`. It won’t emit a tuple with event `b` until `P2` emits another event.
    /// If either upstream publisher finishes successfuly or fails with an error, the zipped publisher does the same.
    ///
    /// - Parameter other: Another publisher.
    ///   - transform: A closure that receives the most recent value from each publisher and returns a new value to publish.
    /// - Returns: A publisher that emits pairs of elements from the upstream publishers as tuples.
    public func zip<P, T>(_ other: P, _ transform: @escaping (Self.Output, P.Output) -> T) -> Publishers.Map<Publishers.Zip<Self, P>, T> where P : Publisher, Self.Failure == P.Failure {
        OpenCombine.Publishers.Zip(self, other).map(transform)
    }

    /// Combines elements from two other publishers and delivers groups of elements as tuples.
    ///
    /// Use ``Publisher/zip(_:_:)-8d7k7`` to return a new publisher that combines the elements from two additional publishers to publish a tuple to the downstream. The returned publisher waits until all three publishers have emitted an event, then delivers the oldest unconsumed event from each publisher as a tuple to the subscriber.
    ///
    /// In this example, `numbersPub`, `lettersPub` and `emojiPub` are each a ``PassthroughSubject``;
    /// ``Publisher/zip(_:_:)-8d7k7`` receives the oldest unconsumed value from each publisher and combines them into a tuple that it republishes to the downstream:
    ///
    ///     let numbersPub = PassthroughSubject<Int, Never>()
    ///     let lettersPub = PassthroughSubject<String, Never>()
    ///     let emojiPub = PassthroughSubject<String, Never>()
    ///
    ///     cancellable = numbersPub
    ///         .zip(lettersPub, emojiPub)
    ///         .sink { print("\($0)") }
    ///     numbersPub.send(1)     // numbersPub: 1      lettersPub:          emojiPub:        zip output: <none>
    ///     numbersPub.send(2)     // numbersPub: 1,2    lettersPub:          emojiPub:        zip output: <none>
    ///     numbersPub.send(3)     // numbersPub: 1,2,3  lettersPub:          emojiPub:        zip output: <none>
    ///     lettersPub.send("A")   // numbersPub: 1,2,3  lettersPub: "A"      emojiPub:        zip output: <none>
    ///     emojiPub.send("😀")    // numbersPub: 2,3    lettersPub: "A"      emojiPub: "😀"   zip output: (1, "A", "😀")
    ///     lettersPub.send("B")   // numbersPub: 2,3    lettersPub: "B"      emojiPub:        zip output: <none>
    ///     emojiPub.send("🥰")    // numbersPub: 3      lettersPub:          emojiPub:        zip output: (2, "B", "🥰")
    ///
    ///     // Prints:
    ///     //  (1, "A", "😀")
    ///     //  (2, "B", "🥰")
    ///
    /// If any upstream publisher finishes successfully or fails with an error, the zipped publisher does the same.
    ///
    /// - Parameters:
    ///   - publisher1: A second publisher.
    ///   - publisher2: A third publisher.
    /// - Returns: A publisher that emits groups of elements from the upstream publishers as tuples.
    public func zip<P, Q>(_ publisher1: P, _ publisher2: Q) -> Publishers.Zip3<Self, P, Q> where P : Publisher, Q : Publisher, Self.Failure == P.Failure, P.Failure == Q.Failure {
        return OpenCombine.Publishers.Zip3(self, publisher1, publisher2)
    }

    /// Combines elements from two other publishers and delivers a transformed output.
    ///
    /// Use ``Publisher/zip(_:_:_:)-9yqi1`` to return a new publisher that combines the elements from two other publishers using a transformation you specify to publish a new value to the downstream subscriber. The returned publisher waits until all three publishers have emitted an event, then delivers the oldest unconsumed event from each publisher together that the operator uses in the transformation.
    ///
    /// In this example, `numbersPub`, `lettersPub` and `emojiPub` are each a ``PassthroughSubject`` that emit values; ``Publisher/zip(_:_:_:)-9yqi1`` receives the oldest value from each publisher and uses the `Int` from `numbersPub` and publishes a string that repeats the <doc://com.apple.documentation/documentation/Swift/String> from `lettersPub` and `emojiPub` that many times.
    ///
    ///     let numbersPub = PassthroughSubject<Int, Never>()
    ///     let lettersPub = PassthroughSubject<String, Never>()
    ///     let emojiPub = PassthroughSubject<String, Never>()
    ///
    ///     cancellable = numbersPub
    ///         .zip(letters, emoji) { anInt, aLetter, anEmoji in
    ///             ("\(String(repeating: anEmoji, count: anInt)) \(String(repeating: aLetter, count: anInt))")
    ///         }
    ///         .sink { print("\($0)") }
    ///
    ///     numbersPub.send(1)     // numbersPub: 1      lettersPub:        emojiPub:            zip output: <none>
    ///     numbersPub.send(2)     // numbersPub: 1,2    lettersPub:        emojiPub:            zip output: <none>
    ///     numbersPub.send(3)     // numbersPub: 1,2,3  lettersPub:        emojiPub:            zip output: <none>
    ///     lettersPub.send("A")   // numbersPub: 1,2,3  lettersPub: "A"    emojiPub:            zip output: <none>
    ///     emojiPub.send("😀")    // numbersPub: 2,3    lettersPub: "A"    emojiPub:"😀"        zip output: "😀 A"
    ///     lettersPub.send("B")   // numbersPub: 2,3    lettersPub: "B"    emojiPub:            zip output: <none>
    ///     emojiPub.send("🥰")    // numbersPub: 3      lettersPub:        emojiPub:"😀", "🥰"  zip output: "🥰🥰 BB"
    ///
    ///     // Prints:
    ///     // 😀 A
    ///     // 🥰🥰 BB
    ///
    /// If any upstream publisher finishes successfully or fails with an error, the zipped publisher does the same.
    ///
    /// - Parameters:
    ///   - publisher1: A second publisher.
    ///   - publisher2: A third publisher.
    ///   - transform: A closure that receives the most-recent value from each publisher and returns a new value to publish.
    /// - Returns: A publisher that uses the `transform` closure to emit new elements, produced by combining the most recent value from three upstream publishers.
    public func zip<P, Q, T>(_ publisher1: P, _ publisher2: Q, _ transform: @escaping (Self.Output, P.Output, Q.Output) -> T) -> Publishers.Map<Publishers.Zip3<Self, P, Q>, T> where P : Publisher, Q : Publisher, Self.Failure == P.Failure, P.Failure == Q.Failure {
        OpenCombine.Publishers.Zip3(self, publisher1, publisher2).map(transform)
    }
}
