
/// it defines a tuple UseCase - Input
public struct Scenario<Input, Output, Error: StringErrorOutput> {
    
    let useCase: UseCase<Input, Output, Error>
    let input: Input
    
    public init(useCase: UseCase<Input, Output, Error>, input: Input) {
        self.useCase = useCase
        self.input = input
    }
}

extension Scenario where Input ==  Void {
    
    public init(useCase: UseCase<Input, Output, Error>) {
        self.init(useCase: useCase, input: ())
    }
}

extension Scenario {
    
    @discardableResult
    public func execute(on scheduler: UseCaseScheduler) -> ScenarioHandler<Output, Error> {
        let handler = ScenarioHandler<Output, Error>(scheduler: scheduler)
        handler.execute(useCase: useCase, input: input)
        return handler
    }
    
    @discardableResult
    public func executeIgnoringError(on scheduler: UseCaseScheduler) -> ScenarioHandler<Output?, Error> {
        let handler = ScenarioHandler<Output?, Error>(scheduler: scheduler)
        handler.executeIgnoringError(useCase: useCase, input: input)
        return handler
    }
}
