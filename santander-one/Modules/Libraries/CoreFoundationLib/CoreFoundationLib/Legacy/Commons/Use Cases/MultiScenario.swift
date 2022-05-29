import Foundation

/// A class to manage mutiple executions of Scenarios concurrently
public class MultiScenario<Output, Error: StringErrorOutput> {
    
    private let handler: MultiScenarioHandler<Error>
    private var output: Output
    
    /// The constructor of the MultiScenario class
    /// - Parameters:
    ///   - scheduler: The scheduler where we want to execute all scenarios
    ///   - initialValue: The initial value of the possible result of the MultiScenario (i.e. [String]())
    public init(handledOn scheduler: UseCaseScheduler, initialValue: Output) {
        self.handler = MultiScenarioHandler(handledOn: scheduler)
        self.output = initialValue
    }
    
    /// A method to add a new Scenario to the MultiScenario
    /// - Parameters:
    ///   - scenario: The scenario to be added
    ///   - isMandatory: If the scenario is mandatory to be executed successfully
    ///   - onSuccess: A block that receives the following data: The current value of `initialValue`, the Scenario output and input.
    @discardableResult
    public func addScenario<UseCaseInput, UseCaseOutput>(_ scenario: Scenario<UseCaseInput, UseCaseOutput, Error>, isMandatory: Bool = true, onSuccess: ((inout Output, UseCaseOutput, UseCaseInput) -> Void)? = nil) -> MultiScenario {
        self.handler.addScenario(scenario, isMandatory: isMandatory) { output in
            onSuccess?(&self.output, output, scenario.input)
        }
        return self
    }
    
    /// A method to add an array of new Scenarios with the same UseCase
    /// - Parameters:
    ///   - scenarios: The Scenarios to be added
    ///   - areMandatory: If the scenarios are mandatory to be executed successfully
    ///   - onSuccess:  A block that receives the following data: The current value of `initialValue`, the Scenario output and input.
    @discardableResult
    public func addScenarios<UseCaseInput, UseCaseOutput>(_ scenarios: [Scenario<UseCaseInput, UseCaseOutput, Error>], areMandatory: Bool = true, onSuccess: ((inout Output, UseCaseOutput, UseCaseInput) -> Void)? = nil) -> MultiScenario {
        scenarios.forEach { scenario in
            self.addScenario(scenario, isMandatory: areMandatory, onSuccess: onSuccess)
        }
        return self
    }
    
    @discardableResult
    public func addScenario<UseCaseInput, UseCaseOutput>(_ scenario: Scenario<UseCaseInput, UseCaseOutput, Error>, isMandatory: Bool = true, completion: @escaping () -> Void) -> MultiScenario {
        self.handler.addScenario(scenario, isMandatory: isMandatory, completion: completion)
        return self
    }
    
    public func asScenarioHandler() -> ScenarioHandler<Output, Error> {
        let handler = ScenarioHandler<Output, Error>(scheduler: self.handler.scheduler)
        onSuccess { output in
            handler.resultHandler.setResult(.finished(.success(output)))
        }.onError { error in
            handler.resultHandler.setResult(.finished(.failure(error)))
        }
        return handler
    }
}

extension MultiScenario {
    
    @discardableResult
    public func onSuccess(_ completion: @escaping (Output) -> Void) -> MultiScenario {
        self.handler.onSuccess {
            completion(self.output)
        }
        return self
    }
    
    @discardableResult
    func onError(_ completion: @escaping (UseCaseError<Error>) -> Void) -> MultiScenario {
        self.handler.onError { error in
            completion(error)
        }
        return self
    }
    
    func setResult(_ result: Result<Void, UseCaseError<Error>>) {
        self.handler.resultHandler.setResult(.finished(result))
    }
}

extension MultiScenario where Output == Void {
    
    public convenience init(handledOn scheduler: UseCaseScheduler) {
        self.init(handledOn: scheduler, initialValue: ())
    }
}

private class MultiScenarioHandler<Error: StringErrorOutput> {
    
    private var dispatchGroup = DispatchGroup()
    private let semaphore = DispatchSemaphore(value: 1)
    let resultHandler = ScenarioResultHandler<Void, Error>()
    let scheduler: UseCaseScheduler
    
    init(handledOn scheduler: UseCaseScheduler) {
        self.scheduler = scheduler
    }
    
    @discardableResult
    func addScenario<UseCaseInput, UseCaseOutput>(_ scenario: Scenario<UseCaseInput, UseCaseOutput, Error>, isMandatory: Bool, onSuccess: ((UseCaseOutput) -> Void)? = nil) -> MultiScenarioHandler {
        self.dispatchGroup.enter()
        scenario
            .execute(on: self.scheduler)
            .onSuccess { output in
                self.semaphore.wait()
                onSuccess?(output)
                self.dispatchGroup.leave()
                self.semaphore.signal()
            }.onError { error in
                guard isMandatory else { return self.dispatchGroup.leave() }
                self.resultHandler.setResult(.finished(.failure(error)))
            }
        self.dispatchGroup.notify(queue: DispatchQueue.main) {
            self.resultHandler.setResult(.finished(.success(())))
        }
        return self
    }
    
    @discardableResult
    func addScenario<UseCaseInput, UseCaseOutput>(_ scenario: Scenario<UseCaseInput, UseCaseOutput, Error>, isMandatory: Bool, completion: @escaping () -> Void) -> MultiScenarioHandler {
        self.dispatchGroup.enter()
        scenario
            .execute(on: self.scheduler)
            .onSuccess { _ in
                self.semaphore.wait()
                completion()
                self.dispatchGroup.leave()
                self.semaphore.signal()
            }.onError { error in
                guard isMandatory else { return self.dispatchGroup.leave() }
                completion()
                self.resultHandler.setResult(.finished(.failure(error)))
            }
        self.dispatchGroup.notify(queue: DispatchQueue.main) {
            self.resultHandler.setResult(.finished(.success(())))
        }
        return self
    }
    
    @discardableResult
    func addScenarios<UseCaseInput, UseCaseOutput>(_ scenarios: [Scenario<UseCaseInput, UseCaseOutput, Error>]) -> MultiScenarioHandler {
        scenarios.forEach { scenario in
            self.addScenario(scenario, isMandatory: true)
        }
        return self
    }
    
    @discardableResult
    func onError(_ onError: @escaping (UseCaseError<Error>) -> Void) -> MultiScenarioHandler {
        self.resultHandler.observe { result in
            guard case let .finished(result) = result, case let .failure(error) = result else { return }
            onError(error)
        }
        return self
    }
    
    @discardableResult
    func onSuccess(_ completion: @escaping () -> Void) -> MultiScenarioHandler {
        self.resultHandler.observe { result in
            guard case let .finished(result) = result, case .success = result else { return }
            completion()
        }
        return self
    }
    
    func finally(_ completion: @escaping () -> Void) {
        self.resultHandler.observe { _ in
            completion()
        }
    }
}
