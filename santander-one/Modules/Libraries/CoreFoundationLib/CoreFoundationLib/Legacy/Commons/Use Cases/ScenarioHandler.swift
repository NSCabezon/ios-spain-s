
/// A class to handle the Scenarios
public class ScenarioHandler<Output, Error: StringErrorOutput> {
    
    private let scheduler: UseCaseScheduler
    let resultHandler = ScenarioResultHandler<Output, Error>()
    
    public init(scheduler: UseCaseScheduler) {
        self.scheduler = scheduler
    }
    
    /// A method that receives a block with the success response of the Scenario
    /// - Parameter onSuccess: The success action with the output of the scenario
    @discardableResult
    public func onSuccess(_ onSuccess: @escaping (Output) -> Void) -> ScenarioHandler {
        self.observe { result in
            guard case let .finished(result) = result, case let .success(output) = result else { return }
            onSuccess(output)
        }
        return self
    }
    
    /// A method that receives a block with the error response of the Scenario
    /// - Parameter onError: The error action with the error output of the scenario
    @discardableResult
    public func onError(_ onError: @escaping (UseCaseError<Error>) -> Void) -> ScenarioHandler {
        self.observe { result in
            guard case let .finished(result) = result, case let .failure(error) = result else { return }
            onError(error)
        }
        return self
    }
    
    /// A method that receives a block called when the Scenario has finished
    /// - Parameter completion: The completion block called when Scenario finished
    public func finally(_ completion: @escaping () -> Void) {
        self.resultHandler.observe { _ in
            completion()
        }
    }
    
    /// A method to execute a new Scenario when the current scenario fails
    /// - Parameter scenario: The new scenario given the error of the current scenario
    /// - Returns: The scenario handler
    @discardableResult
    public func thenOnError<ThenInput, ThenOutput>(scenario: @escaping (UseCaseError<Error>) -> Scenario<ThenInput, ThenOutput, Error>?) -> ScenarioHandler<ThenOutput, Error> {
        let handler = ScenarioHandler<ThenOutput, Error>(scheduler: self.scheduler)
        self.observe { output in
            switch output {
            case .finished(let result):
                switch result {
                case .failure(let error):
                    guard let scenario = scenario(error) else {
                        handler.resultHandler.setResult(.finishedWithoutResult)
                        return
                    }
                    handler.execute(useCase: scenario.useCase, input: scenario.input)
                case .success:
                    break
                }
            case .finishedWithoutResult:
                break
            }
        }
        return handler
    }
}

extension ScenarioHandler {
    @discardableResult func execute<Input>(useCase: UseCase<Input, Output, Error>, input: Input) -> Cancelable {
        return self.scheduler.schedule(useCase: useCase, input: input) { result in
            self.resultHandler.setResult(.finished(result))
        }
    }
    
    @discardableResult func executeIgnoringError<Input, UseCaseOutput>(useCase: UseCase<Input, UseCaseOutput, Error>, input: Input) -> Cancelable where Output == UseCaseOutput? {
        return self.scheduler.schedule(useCase: useCase, input: input) { result in
            self.resultHandler.setResult(.finished(result.map({ $0 })))
        }
    }
}

// MARK: - Operators

extension ScenarioHandler {
    
    public func just(_ output: Output) -> ScenarioHandler<Output, Error> {
        let handler = ScenarioHandler<Output, Error>(scheduler: self.scheduler)
        handler.resultHandler.setResult(.finished(.success(output)))
        return handler
    }
    
    public func filter(_ filter: @escaping (Output) -> Bool) -> ScenarioHandler<Output, Error> {
        let handler = ScenarioHandler<Output, Error>(scheduler: self.scheduler)
        self.observe { output in
            switch output {
            case .finished(let result):
                switch result {
                case .failure(let error):
                    handler.resultHandler.setResult(.finished(.failure(error)))
                case .success(let output):
                    guard filter(output) == true else { return handler.resultHandler.setResult(.finishedWithoutResult) }
                    handler.resultHandler.setResult(.finished(.success(output)))
                }
            case .finishedWithoutResult:
                break
            }
        }
        return handler
    }
    
    public func map<NewOutput>(_ transform: @escaping (Output) -> NewOutput) -> ScenarioHandler<NewOutput, Error> {
        let handler = ScenarioHandler<NewOutput, Error>(scheduler: self.scheduler)
        self.observe { output in
            switch output {
            case .finished(let result):
                switch result {
                case .failure(let error):
                    handler.resultHandler.setResult(.finished(.failure(error)))
                case .success(let output):
                    handler.resultHandler.setResult(.finished(.success(transform(output))))
                }
            case .finishedWithoutResult:
                break
            }
        }
        return handler
    }
    
    public func mapError(_ transform: @escaping (UseCaseError<Error>) -> Output) -> ScenarioHandler<Output, Error> {
        let handler = ScenarioHandler<Output, Error>(scheduler: self.scheduler)
        self.observe { output in
            switch output {
            case .finished(let result):
                switch result {
                case .failure(let error):
                    handler.resultHandler.setResult(.finished(.success(transform(error))))
                case .success(let output):
                    handler.resultHandler.setResult(.finished(.success(output)))
                }
            case .finishedWithoutResult:
                break
            }
        }
        return handler
    }
}

// MARK: - Chaining of MultiScenario

extension ScenarioHandler {

    /// A method to execute a new MultiScenario given the current ScenarioHandler
    /// - Parameters:
    ///   - multiScenario: A block that receives the output of the current Scenario and returns a Multiscenario
    /// - Returns: The scenario handler
    @discardableResult
    public func then<MultiScenarioOutput>(multiScenario: @escaping (Output) -> MultiScenario<MultiScenarioOutput, Error>) -> ScenarioHandler<MultiScenarioOutput, Error> {
        let handler = ScenarioHandler<MultiScenarioOutput, Error>(scheduler: self.scheduler)
        self.observe { output in
            switch output {
            case .finished(let result):
                switch result {
                case .failure(let error):
                    handler.resultHandler.setResult(.finished(.failure(error)))
                case .success(let output):
                    multiScenario(output)
                        .onSuccess { output in
                            handler.resultHandler.setResult(.finished(.success(output)))
                        }.onError { error in
                            handler.resultHandler.setResult(.finished(.failure(error)))
                        }
                }
            case .finishedWithoutResult:
                break
            }
        }
        return handler
    }
    
    /// A method to execute a new MultiScenario given the current ScenarioHandler..
    /// - Parameters:
    ///   - multiScenario: A block that receives the output of the current Scenario and returns an optional Multiscenario
    ///   - outputWhenNil: The default output in case the next Multiscenario is nil. In case of nil, a success response will be propagated to next ScenarioHandler
    /// - Returns: The scenario handler
    @discardableResult
    public func then<ThenOutput>(multiScenario: @escaping (Output) -> MultiScenario<ThenOutput, Error>?, outputWhenNil: ThenOutput? = nil) -> ScenarioHandler<ThenOutput, Error> {
        let handler = ScenarioHandler<ThenOutput, Error>(scheduler: self.scheduler)
        self.observe { output in
            switch output {
            case .finished(let result):
                switch result {
                case .failure(let error):
                    handler.resultHandler.setResult(.finished(.failure(error)))
                case .success(let output):
                    guard let multiScenario = multiScenario(output) else {
                        let result: ScenarioResultHandler<ThenOutput, Error>.ScenarioResult = outputWhenNil.flatMap({ .finished(.success($0)) }) ?? .finishedWithoutResult
                        return handler.resultHandler.setResult(result)
                    }
                    multiScenario
                        .onSuccess { output in
                            handler.resultHandler.setResult(.finished(.success(output)))
                        }.onError { error in
                            handler.resultHandler.setResult(.finished(.failure(error)))
                        }
                }
            case .finishedWithoutResult:
                break
            }
        }
        return handler
    }
}

// MARK: - Chaining of ScenarioHandler

extension ScenarioHandler {
    
    /// A method to execute a new ScenarioHandler given the current ScenarioHandler.
    /// - Parameters:
    ///   - handler: The next scenario handler to be performed
    ///   - outputWhenNil: The default output in case the next handler is nil. In case of nil, a success response will be propagated to next ScenarioHandler
    /// - Returns: The new Scenario handler
    public func then<ThenOutput>(handler: @escaping (Output) -> ScenarioHandler<ThenOutput, Error>?, outputWhenNil: ThenOutput? = nil) -> ScenarioHandler<ThenOutput, Error> {
        let newHandler = ScenarioHandler<ThenOutput, Error>(scheduler: scheduler)
        self.observe { output in
            switch output {
            case .finished(let result):
                switch result {
                case .failure(let error):
                    newHandler.resultHandler.setResult(.finished(.failure(error)))
                case .success(let output):
                    guard let scenarioHandler = handler(output) else {
                        let result: ScenarioResultHandler<ThenOutput, Error>.ScenarioResult = outputWhenNil.flatMap({ .finished(.success($0)) }) ?? .finishedWithoutResult
                        return newHandler.resultHandler.setResult(result)
                    }
                    scenarioHandler
                        .onSuccess { result in
                            newHandler.resultHandler.setResult(.finished(.success(result)))
                        }.onError { error in
                            newHandler.resultHandler.setResult(.finished(.failure(error)))
                        }
                }
            case .finishedWithoutResult:
                break
            }
        }
        return newHandler
    }
}

// MARK: - Chaining of scenarios

extension ScenarioHandler {
    
    /// A method to execute a new Scenario given the current ScenarioHandler
    /// - Parameter scenario: The new Scenario to be executed
    /// - Returns: The scenario handler
    @discardableResult
    public func then<ThenInput, ThenOutput>(scenario: @escaping (Output) -> Scenario<ThenInput, ThenOutput, Error>?, outputWhenNil: ThenOutput? = nil) -> ScenarioHandler<ThenOutput, Error> {
        return self.then(scenario: scenario, scheduler: self.scheduler, outputWhenNil: outputWhenNil)
    }
    
    /// A method to execute a new Scenario in a given ScenarioHandler. If the new Scenario is nil, a success response will be propagated to the next ScenarioHandler.
    /// - Parameters:
    ///   - scenario: The new Scenario to be executed
    ///   - scheduler: The scheduler  where the scenario will be run on
    ///   - outputWhenNil: The default output in case the next scenario is nil. In case of nil, a success response will be propagated to next ScenarioHandler
    /// - Returns: The new Scenario handler
    @discardableResult
    public func then<ThenInput, ThenOutput>(scenario: @escaping (Output) -> Scenario<ThenInput, ThenOutput, Error>?, scheduler: UseCaseScheduler, outputWhenNil: ThenOutput? = nil) -> ScenarioHandler<ThenOutput, Error> {
        let handler = ScenarioHandler<ThenOutput, Error>(scheduler: scheduler)
        self.observe { output in
            switch output {
            case .finished(let result):
                switch result {
                case .failure(let error):
                    handler.resultHandler.setResult(.finished(.failure(error)))
                case .success(let output):
                    guard let scenario = scenario(output) else {
                        let result: ScenarioResultHandler<ThenOutput, Error>.ScenarioResult = outputWhenNil.flatMap({ .finished(.success($0)) }) ?? .finishedWithoutResult
                        return handler.resultHandler.setResult(result)
                    }
                    handler.execute(useCase: scenario.useCase, input: scenario.input)
                }
            case .finishedWithoutResult:
                break
            }
        }
        return handler
    }
    
    /// A method to execute a new Scenario given the current ScenarioHandler (ignoring the result of the previous scenario)
    /// - Parameter scenario: The new Scenario to be executed
    /// - Returns: The scenario handler
    @discardableResult
    public func thenIgnoringPreviousResult<ThenInput, ThenOutput>(scenario: @escaping () -> Scenario<ThenInput, ThenOutput, Error>?) -> ScenarioHandler<ThenOutput, Error> {
        let handler = ScenarioHandler<ThenOutput, Error>(scheduler: self.scheduler)
        self.observe { output in
            switch output {
            case .finished:
                guard let scenario = scenario() else {
                    handler.resultHandler.setResult(.finishedWithoutResult)
                    return
                }
                handler.execute(useCase: scenario.useCase, input: scenario.input)
            case .finishedWithoutResult:
                break
            }
        }
        return handler
    }
    
    /// A method to execute a new Scenario given the current ScenarioHandler (ignoring the error of next scenario)
    /// - Parameter scenario: The new Scenario to be executed
    /// - Returns: The new scenario handler
    @discardableResult
    public func thenIgnoringError<ThenInput, ThenOutput>(scenario: @escaping (Output) -> Scenario<ThenInput, ThenOutput, Error>?) -> ScenarioHandler<ThenOutput?, Error> {
        let handler = ScenarioHandler<ThenOutput?, Error>(scheduler: self.scheduler)
        self.observe { output in
            switch output {
            case .finished(let result):
                switch result {
                case .failure(let error):
                    handler.resultHandler.setResult(.finished(.failure(error)))
                case .success(let output):
                    guard let scenario = scenario(output) else {
                        handler.resultHandler.setResult(.finishedWithoutResult)
                        return
                    }
                    handler.executeIgnoringError(useCase: scenario.useCase, input: scenario.input)
                }
            case .finishedWithoutResult:
                break
            }
        }
        return handler
    }
    
    @available(*, deprecated, message: "Use thenIgnoringPreviousResult(scenario:) instead")
    @discardableResult
    public func then<ThenInput, ThenOutput>(scenario: @escaping () -> Scenario<ThenInput, ThenOutput, Error>?) -> ScenarioHandler<ThenOutput, Error> {
        let handler = ScenarioHandler<ThenOutput, Error>(scheduler: self.scheduler)
        self.observe { _ in
            guard let scenario = scenario() else {
                handler.resultHandler.setResult(.finishedWithoutResult)
                return
            }
            handler.execute(useCase: scenario.useCase, input: scenario.input)
        }
        return handler
    }
}

private extension ScenarioHandler {
    func observe(using callback: @escaping (ScenarioResultHandler<Output, Error>.ScenarioResult) -> Void) {
        self.resultHandler.observe(using: callback)
    }
}

class ScenarioResultHandler<Output, Error: StringErrorOutput> {
    
    /// The Scenario Result
    /// - finishedWithoutResult: When the scenario can not be finished due to a failed `then` (e.g. .`then(scenario: { somethingThatCanBeNil($0) })`)
    /// - finished: When the scenario finished correctly with some of this states: successfully o with an error
    enum ScenarioResult {
        case finishedWithoutResult
        case finished(Result<Output, UseCaseError<Error>>)
    }
    
    private var result: ScenarioResult? {
        didSet {
            self.result.map(self.report)
        }
    }
    private var callbacks: [(ScenarioResult) -> Void] = []
    
    private func report(result: ScenarioResult) {
        self.callbacks.forEach { $0(result) }
        self.callbacks = []
    }
    
    func setResult(_ result: ScenarioResult) {
        self.result = result
    }
    
    func observe(using callback: @escaping (ScenarioResult) -> Void) {
        guard let result = self.result else { return self.callbacks.append(callback) }
        callback(result)
    }
}
