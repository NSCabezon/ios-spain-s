//
//  PublishRelay+Combine.swift
//  RxCombine
//
//  Created by Shai Mishali on 10/05/2020.
//


import OpenCombine
import RxSwift
import RxRelay

// MARK: - Publish Relay as Combine Subject

/// A bi-directional wrapper for a RxSwift Publish Relay

public final class RxPassthroughRelay<Output>: OpenCombine.Subject {
    private let rxRelay: PublishRelay<Output>
    private let subject = PassthroughSubject<Output, Never>()
    private let subscription: AnyCancellable?

    init(rxRelay: PublishRelay<Output>) {
        self.rxRelay = rxRelay
        subscription = rxRelay.publisher.subscribe(subject)
    }

    public func receive<S: Subscriber>(subscriber: S) where Failure == S.Failure, Output == S.Input {
        subject.receive(subscriber: subscriber)
    }

    public func send(_ value: Output) {
        rxRelay.accept(value)
    }

    public func send(completion: Subscribers.Completion<Failure>) {
        // Relays can't complete or fail
    }

    public func send(subscription: Subscription) {
        subject.send(subscription: subscription)
    }

    deinit { subscription?.cancel() }

    public typealias Failure = Never
}


public extension PublishRelay {
    func toCombine() -> RxPassthroughRelay<Element> {
        RxPassthroughRelay(rxRelay: self)
    }
}

