//
//  UseCaseHandler.swift
//  Commons
//
//  Created by José Carlos Estela Anguita on 1/12/20.
//


// Extension of old UseCaseHandler using UseCaseWrapper for retro-compatibility
extension UseCaseHandler: UseCaseScheduler {
    
    @discardableResult public func schedule<Input, Output, Error: StringErrorOutput>(useCase: UseCase<Input, Output, Error>, input: Input, completion: @escaping (Result<Output, UseCaseError<Error>>) -> Void) -> Cancelable {
        return UseCaseWrapper(
            with: useCase.setRequestValues(requestValues: input),
            useCaseHandler: self,
            onSuccess: { result in
                completion(.success(result))
            },
            onError: { error in
                completion(.failure(error))
            }
        )
    }
}
