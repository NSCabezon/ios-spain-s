//
//  DispatchQueue+UseCaseScheduler.swift
//  Account
//
//  Created by José Carlos Estela Anguita on 26/1/21.
//


extension DispatchQueue: UseCaseScheduler {
    @discardableResult public func schedule<Input, Output, Error: StringErrorOutput>(
        useCase: UseCase<Input, Output, Error>,
        input: Input,
        completion: @escaping (Result<Output, UseCaseError<Error>>) -> Void
    ) -> Cancelable {
        let work = DispatchWorkItem(block: {
            self.syncCall(useCase: useCase, input: input) { result in
                DispatchQueue.main.async {
                    completion(result)
                }
            }
        })
        if self == DispatchQueue.main {
            work.perform()
        } else {
            self.async(execute: work)
        }
        return work
    }
}

private extension DispatchQueue {
    func syncCall<Input, Output, Error: StringErrorOutput>(
        useCase: UseCase<Input, Output, Error>,
        input: Input,
        completion: @escaping (Result<Output, UseCaseError<Error>>) -> Void
    ) {
        do {
            let response = try useCase.executeUseCase(requestValues: input)
            if response.isOkResult {
                let success = try response.getOkResult()
                completion(.success(success))
            } else {
                let error = try response.getErrorResult()
                completion(.failure(.error(error)))
            }
        } catch {
            completion(.failure(.generic))
        }
    }
}

extension DispatchWorkItem: Cancelable {}
