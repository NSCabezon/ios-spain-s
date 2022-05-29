//
//  ReactiveOperative.swift
//  Operative
//
//  Created by José Carlos Estela Anguita on 7/1/22.
//

import Foundation
import OpenCombine
import UI
import CoreFoundationLib

/// A protocol that defines an operative
public protocol ReactiveOperative: AnyObject {
    associatedtype StepType: Equatable
    /// The current progress of the operative
    var progress: Progress { get }
    /// The steps coordinator that will handle all the operative steps
    var stepsCoordinator: StepsCoordinator<StepType> { get }
    /// An array of publishers that will be executed when the operative will start as conditions. In case of failure, an error will be shown.
    var willStartConditions: [AnyPublisher<ConditionState, Never>] { get set }
    /// An array of publisher that will be executed when the operative will finish as conditions. In case of failure, an error will be shown.
    var willFinishConditions: [AnyPublisher<ConditionState, Never>] { get set }
    /// An array of publisher that will be executed when the operative will show the next step as conditions. In case of failure, an error will be shown.
    var willShowNextConditions: [AnyPublisher<ConditionState, Never>] { get set }
    /// The array of capabilities of the operative
    var capabilities: [AnyCapability] { get set }
    var coordinator: OperativeCoordinator { get }
    var subscriptions: Set<AnyCancellable> { get set }
    func start()
    func next()
    func back()
    func finish()
    func back(to step: StepType)
}

extension ReactiveOperative {
    
    public var progress: Progress {
        return stepsCoordinator.progress
    }
    
    public func start() {
        bindDidFinish()
        capabilities.forEach { $0.configure() }
        perform(conditions: willStartConditions) { [weak self] in
            self?.stepsCoordinator.start()
        }
    }
    
    public func next() {
        perform(conditions: willShowNextConditions) { [weak self] in
            self?.stepsCoordinator.next()
        }
    }
    
    public func back() {
        stepsCoordinator.back()
    }
    
    public func finish() {
        perform(conditions: willFinishConditions) { [weak self] in
            self?.coordinator.dismiss()
        }
    }
    
    public func back(to step: StepType) {
        stepsCoordinator.back(to: step)
    }
}

public enum ConditionState: State {
    case success
    case failure
}

private extension ReactiveOperative {
    
    func perform(conditions publishers: [AnyPublisher<ConditionState, Never>], action: @escaping () -> Void) {
        guard publishers.count > 0 else { return action() }
        publishers
            .serialized() // Performs every publisher serially
            .sink(receiveValue: action)
            .store(in: &subscriptions)
    }
    
    func bindDidFinish() {
        stepsCoordinator.didFinishPublisher
            .sink { [weak self] in
                self?.willStartConditions.removeAll()
                self?.willFinishConditions.removeAll()
                self?.willShowNextConditions.removeAll()
                self?.capabilities.removeAll()
                self?.coordinator.onFinish?()
            }
            .store(in: &subscriptions)
    }
}

private extension Collection where Element: Publisher, Element.Output == ConditionState, Element.Failure == Never {
    
    func serialized() -> AnyPublisher<Void, Never> {
        guard let start = first else { return Just(()).eraseToAnyPublisher() }
        return dropFirst().reduce(start.eraseToAnyPublisher(), nextPartialResult)
        .filter({ $0 == .success })
        .map({ _ in return () })
        .eraseToAnyPublisher()
    }
    
    func nextPartialResult(having previous: AnyPublisher<ConditionState, Never>, next: Element) -> AnyPublisher<ConditionState, Never> {
        return previous
            .flatMap { condition -> AnyPublisher<ConditionState, Never> in
                guard condition == .success else { return Just(.failure).eraseToAnyPublisher() }
                return next.eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}
