//
//  Publishers.MergeMany.swift
//  Operative
//
//  Created by José Carlos Estela Anguita on 10/1/22.
//

import Foundation
import OpenCombine
import RxSwift

extension OpenCombine.Publishers {
    
    public struct MergeMany<Upstream>: Publisher where Upstream: Publisher {
        
        /// The kind of values published by this publisher.
        public typealias Output = Upstream.Output
        
        /// The kind of errors this publisher might publish.
        ///
        /// Use `Never` if this `Publisher` does not publish errors.
        public typealias Failure = Upstream.Failure
        
        public let publishers: [Upstream]
        
        public init(_ upstream: Upstream...) {
            self.publishers = upstream
        }
        
        public init<S>(_ upstream: S) where Upstream == S.Element, S: Swift.Sequence {
            self.publishers = Array(upstream)
        }
        
        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where S : Subscriber, Upstream.Failure == S.Failure, Upstream.Output == S.Input {
            Observable.merge(publishers.map { $0.asObservable() } )
                .asPublisher()
                .mapError { $0 as! S.Failure }
                .subscribe(subscriber)
        }
        
        public func merge(with other: Upstream) -> Publishers.MergeMany<Upstream> {
            return MergeMany(self.publishers + [other])
        }
    }
}
