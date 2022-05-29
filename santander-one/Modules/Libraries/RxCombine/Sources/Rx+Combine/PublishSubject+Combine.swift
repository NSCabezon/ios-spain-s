//
//  PublishSubject+Combine.swift
//  RxCombine
//
//  Created by Shai Mishali on 10/05/2020.
//  Copyright © 2019 Combine Community. All rights reserved.
//


import OpenCombine
import RxSwift

// MARK: - Behavior Subject as Combine Subject

/// A bi-directional wrapper for a RxSwift Publish Subject

public final class RxPassthroughSubject<Output>: OpenCombine.Subject {
    private let rxSubject: PublishSubject<Output>
    private let subject = PassthroughSubject<Output, Failure>()
    private let subscription: AnyCancellable?

    init(rxSubject: PublishSubject<Output>) {
        self.rxSubject = rxSubject
        subscription = rxSubject.publisher.subscribe(subject)
    }

    public func receive<S: Subscriber>(subscriber: S) where Failure == S.Failure, Output == S.Input {
        subject.receive(subscriber: subscriber)
    }

    public func send(_ value: Output) {
        rxSubject.onNext(value)
    }

    public func send(completion: Subscribers.Completion<Failure>) {
        switch completion {
        case .finished:
            rxSubject.onCompleted()
        case .failure(let error):
            rxSubject.onError(error)
        }
    }

    public func send(subscription: Subscription) {
        subject.send(subscription: subscription)
    }

    deinit { subscription?.cancel() }

    public typealias Failure = Swift.Error
}


public extension PublishSubject {
    func toCombine() -> RxPassthroughSubject<Element> {
        RxPassthroughSubject(rxSubject: self)
    }
}

