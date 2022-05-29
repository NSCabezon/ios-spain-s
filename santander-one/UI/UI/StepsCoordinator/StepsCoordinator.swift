//
//  StepsCoordinator.swift
//  UI
//
//  Created by Jose Carlos Estela Anguita on 11/10/2019.
//

import UIKit
import CoreFoundationLib
import OpenCombine

public class StepsCoordinator<StepType: Equatable> {
    
    public typealias StepAndView = (step: StepType, view: UIViewController)

    /// Returns the total `enabled` steps
    public var totalSteps: Int {
        return steps.filter({ $0.state == .enabled }).count
    }
    /// A publisher that will emit when the current progress have changed
    public var progressPublisher: AnyPublisher<Progress, Never> {
        return currentStep
            .map { [weak self] in
                guard let totalSteps = self?.totalSteps else { return Progress(current: $0, total: 0) }
                return Progress(current: $0, total: totalSteps)
            }
            .eraseToAnyPublisher()
    }
    /// The current progress of the steps (current & total)
    public var progress: Progress {
        return Progress(current: currentStep.value, total: totalSteps)
    }
    /// A publisher that will emit when the next step will be shown
    public var willShowNextPublisher: AnyPublisher<StepAndView, Never> {
        return willShowNextSubject.eraseToAnyPublisher()
    }
    /// A publisher that will emit when the previous step will be shown
    public var willShowPreviousPublisher: AnyPublisher<StepAndView, Never> {
        return willShowPreviousSubject.eraseToAnyPublisher()
    }
    /// A publisher that will emit when the next step has been shown
    public var didShowNextPublisher: AnyPublisher<StepAndView, Never> {
        return didShowNextSubject.eraseToAnyPublisher()
    }
    /// A publisher that will emit when the previous step has been shown
    public var didShowPreviousPublisher: AnyPublisher<StepAndView, Never> {
        return didShowPreviousSubject.eraseToAnyPublisher()
    }
    /// A publisher that will emit when the steps coordinator will finish
    public var willFinishPublisher: AnyPublisher<Void, Never> {
        return willFinishSubject.eraseToAnyPublisher()
    }
    /// A publisher that will emit when the steps coordinator did finish
    public var didFinishPublisher: AnyPublisher<Void, Never> {
        return didFinishSubject.eraseToAnyPublisher()
    }
    /// A closure that indicates if a step should be shown
    public lazy var shouldShowStep: (StepType) -> Bool = {
        return { _ in return true }
    }()
    /// A property that returns the current step
    public var current: Step {
        return steps[currentStep.value]
    }
    public var steps: [Step]
    
    private weak var navigationController: UINavigationController?
    private let provider: (StepType) -> StepIdentifiable
    private let currentStep = CurrentValueSubject<Int, Never>(-1)
    private var subscriptions: Set<AnyCancellable> = []
    private lazy var willShowNextSubject: PassthroughSubject<StepAndView, Never> = PassthroughSubject()
    private lazy var willShowPreviousSubject: PassthroughSubject<StepAndView, Never> = PassthroughSubject()
    private lazy var didShowNextSubject: PassthroughSubject<StepAndView, Never> = PassthroughSubject()
    private lazy var didShowPreviousSubject: PassthroughSubject<StepAndView, Never> = PassthroughSubject()
    private lazy var willFinishSubject: PassthroughSubject<Void, Never> = PassthroughSubject()
    private lazy var didFinishSubject: PassthroughSubject<Void, Never> = PassthroughSubject()
    
    /// Create an instance of the StepsCoordinator
    /// - Parameters:
    ///   - navigationController: The navigation controller
    ///   - provider: A closure that will return every `StepIdentifiable` for each `Step`
    ///   - steps: The array of the `Step`s
    public init(navigationController: UINavigationController?, provider: @escaping (StepType) -> StepIdentifiable, steps: [Step]) {
        self.provider = provider
        self.navigationController = navigationController
        self.steps = steps
    }
}

public extension StepsCoordinator {
    
    enum State {
        case enabled
        case disabled
    }
    
    /// Defines a Step with a state
    struct Step: Equatable {
        
        public let type: StepType
        public let state: State
        
        public init(type: StepType, state: State = .enabled) {
            self.type = type
            self.state = state
        }
        
        public static func step(_ type: StepType, state: State = .enabled) -> Step {
            return Step(type: type, state: state)
        }
        
        public static func == (lhs: Step, rhs: Step) -> Bool {
            return lhs.type == rhs.type
        }
    }
    
    /// A convenience init that allows to create a StepsCoordinator giving a `StepType` that conforms `CaseIterable`
    /// - Note:
    /// ```
    /// enum Step: CaseIterable {
    ///    case step1
    ///    case step2
    /// }
    /// ```
    /// This is equivalent to create a `StepsCoordinator<AnyProvider>(navigationController: navigationController, provider: provider, steps: [.step(.step1), .step(.step2)])
    convenience init(navigationController: UINavigationController?, provider: @escaping (StepType) -> StepIdentifiable) where StepType: CaseIterable {
        self.init(
            navigationController: navigationController,
            provider: provider,
            steps: StepType.allCases.map({ Step(type: $0, state: .enabled) })
        )
    }
    
    /// Use this method to start the process. This will navigate to the first enabled step.
    func start() {
        next()
    }
    
    /// Use this method to navigate to the next enabled step. In case of no next step available, `finish()` will be called
    func next() {
        let nextIndex = currentStep.value + 1
        guard let next = steps
            .enumerated()
            .suffix(steps.count - nextIndex)
            .first(where: { $0.element.state == .enabled && shouldShowStep($0.element.type) })
        else {
            return finish()
        }
        let view = provider(next.element.type)
        willShowNextSubject.send(StepAndView(step: next.element.type, view: view))
        navigationController?.pushViewController(view, animated: true) { [weak self] in
            self?.didShowNextSubject.send(StepAndView(step: next.element.type, view: view))
        }
        currentStep.send(next.offset)
    }
    
    /// Use this method to navigate to the previous step
    func back() {
        guard currentStep.value > 0,
              let previous = steps
                .enumerated()
                .prefix(currentStep.value)
                .reversed()
                .first(where: { $0.element.state == .enabled && shouldShowStep($0.element.type) }),
              let previousView = navigationController?.viewControllers.dropLast().last
        else {
            return finish()
        }
        willShowPreviousSubject.send(StepAndView(step: previous.element.type, view: previousView))
        navigationController?.popViewController(animated: true) { [weak self] in
            self?.didShowPreviousSubject.send(StepAndView(step: previous.element.type, view: previousView))
        }
        currentStep.send(previous.offset)
    }
    
    /// Use this method to navigate to a previous step. If the step is not in the navigation stack, this method will create it in the proper index.
    /// - Parameter step: The step you want to go back
    func back(to step: StepType) {
        guard
            let viewController = navigationController?.viewControllers.steps().first(where: { stepName(for: $0) == stepName(for: step) }),
            let index = steps.firstIndex(where: { $0.type == step })
        else {
            return goBackAndCreate(step: step)
        }
        willShowPreviousSubject.send(StepAndView(step: step, view: viewController))
        navigationController?.popToViewController(viewController, animated: true)
        currentStep.send(index)
    }
    
    /// Use this method to add a step after the given step
    /// - Parameters:
    ///   - step: The step to be added
    ///   - current: The step that will be the previous of our new step
    func add(step: StepType, after current: StepType) {
        guard !steps.contains(where: { $0.type == step }) else { return }
        guard let index = steps.safeIndex(after: Step(type: current)) else { return steps.insert(Step(type: step), at: steps.endIndex) }
        steps.insert(Step(type: step), at: index)
    }
    
    /// Use this method to add a step before the given step
    /// - Parameters:
    ///   - step: The step to be added
    ///   - current: The step that will be the next of our new step
    func add(step: StepType, before current: StepType) {
        guard !steps.contains(where: { $0.type == step }) else { return } 
        guard let index = steps.safeIndex(before: Step(type: current)) else { return steps.insert(Step(type: step), at: 0) }
        steps.insert(Step(type: step), at: index)
    }
    
    /// Use this method to remove a step (NOTE: if the step is the current step, this method will not navigate to anywhere)
    /// - Parameter step: The step to be removed
    func remove(step: StepType) {
        guard let index = steps.firstIndex(where: { $0.type == step }) else { return }
        steps.remove(at: index)
    }
    
    /// Use this method to update the state of a specific step
    /// - Parameters:
    ///   - state: The state of the step to be changed
    ///   - step: The step to be updated
    func update(state: State, for step: StepType) {
        steps = steps.map {
            guard $0.type == step else { return $0 }
            return Step(type: step, state: state)
        }
    }
    
    /// Use this method to finalize the steps coordinator and go back to the previous viewcontroller in navigation stack
    func finish() {
      finish {
        guard
        let navigationController = self.navigationController,
        let first = self.steps.filter({ $0.state == .enabled }).first,
        let viewController = navigationController.viewControllers.steps().first(where: { self.stepName(for: $0) == self.stepName(for: first) }),
        let previousViewController = navigationController.viewControllers.item(before: viewController)
        else {
          return
        }
        navigationController.popToViewController(previousViewController, animated: true)
      }
    }
    
    /// Use this method to finalize the steps coordinator and perform a custom action for finishing it
    func finish(onFinishAction action: @escaping () -> Void) {
      willFinishSubject.send()
      action()
      currentStep.send(-1)
      didFinishSubject.send()
    }
}

private extension StepsCoordinator {
    
    /// This method is called when a `StepType` has to be created when we go back. Basically, it should be called when we want to go `back(to: .any)` and `.any` is not in the navigation stack.
    /// - Parameter step: The step to be created
    func goBackAndCreate(step: StepType) {
        let enabledSteps = steps.filter({ $0.state == .enabled })
        guard
            let sameStep = enabledSteps.first(where: { $0.type == step }),
            let previous = enabledSteps.item(before: sameStep),
            let previousIndex = steps.firstIndex(of: previous),
            let viewController = navigationController?.viewControllers.steps().first(where: { stepName(for: $0) == stepName(for: previous) })
        else {
            return goBackAndCreateTheFirst(step: step)
        }
        navigationController?.popToViewController(viewController, animated: false)
        currentStep.send(previousIndex)
        next()
    }
    
    /// This method is called when a `StepType` has to be created when we go back and that step is the **first** one . Basically, it should be called when we want to go `back(to: .any)`, `.any` is not in the navigation stack and is the first step.
    /// - Parameter step: The step to be created
    func goBackAndCreateTheFirst(step: StepType) {
        let currentSteps = steps.filter({ $0.state == .enabled && $0.type != step })
        guard
            let navigationController = navigationController,
            let first = currentSteps.first,
            let viewController = navigationController.viewControllers.steps().first(where: { stepName(for: $0) == stepName(for: first) }),
            let previousViewController = navigationController.viewControllers.item(before: viewController)
        else {
            return
        }
        navigationController.popToViewController(previousViewController, animated: false)
        currentStep.send(-1)
        next()
    }
    
    func stepName(for step: StepType) -> String {
        return stepName(for: provider(step))
    }
    
    func stepName(for step: Step) -> String {
        return stepName(for: step.type)
    }
    
    func stepName(for step: StepIdentifiable) -> String {
        return type(of: step).stepName
    }
}

private extension Array where Element == UIViewController {
    
    func steps() -> [StepIdentifiable] {
        return compactMap { $0 as? StepIdentifiable }
    }
}

private extension Collection where Iterator.Element: Equatable {
    typealias Element = Self.Iterator.Element
    
    func safeIndex(after index: Index) -> Index? {
        let nextIndex = self.index(after: index)
        return (nextIndex < self.endIndex) ? nextIndex : nil
    }
    
    func safeIndex(after item: Element) -> Index? {
        return self.firstIndex(of: item)
            .flatMap(self.safeIndex(after:))
    }
    
    func item(after item: Element) -> Element? {
        return safeIndex(after: item)
            .map { self[$0] }
    }
}

private extension BidirectionalCollection where Iterator.Element: Equatable {
    typealias Element = Self.Iterator.Element
    
    func safeIndex(before index: Index) -> Index? {
        let previousIndex = self.index(before: index)
        return (self.startIndex <= previousIndex) ? previousIndex : nil
    }
    
    func safeIndex(before item: Element) -> Index? {
        return self.firstIndex(of: item)
            .flatMap(safeIndex(before:))
    }
    
    func item(before item: Element) -> Element? {
        return self.firstIndex(of: item)
            .flatMap(safeIndex(before:))
            .map { self[$0] }
    }
}

extension Progress {
    
    public convenience init(current: Int, total: Int) {
        self.init(totalUnitCount: Int64(total))
        completedUnitCount = Int64(current + 1)
    }
    
    public var current: Int {
        return Int(completedUnitCount - 1)
    }
    
    public var total: Int {
        return Int(totalUnitCount)
    }
}
