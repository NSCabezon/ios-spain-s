
/// A protocol that should implement any class that wants to handle UseCases
public protocol UseCaseScheduler {
    @discardableResult func schedule<Input, Output, Error: StringErrorOutput>(useCase: UseCase<Input, Output, Error>, input: Input, completion: @escaping (Result<Output, UseCaseError<Error>>) -> Void) -> Cancelable
}
