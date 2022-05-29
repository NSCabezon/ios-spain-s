import CoreFoundationLib
import Foundation

public class UseCaseWrapper<Input, Response, Error: StringErrorOutput> {
    var onSuccess: ((Response) -> Void)?
    var onError: ((Error?) -> Void)?
    var onGenericErrorType: ((UseCaseError<Error>) -> Void)?
    private weak var operation: UseCaseOperation?
    
    @discardableResult
    public init(with useCase: UseCase<Input, Response, Error>, useCaseHandler: UseCaseHandler, errorHandler: UseCaseErrorHandler? = nil, includeAllExceptions: Bool = false, queuePriority: Foundation.Operation.QueuePriority = Foundation.Operation.QueuePriority.normal, finishQueue: UseCaseOperationFinishQueue = .mainThread, onSuccess: ((Response) -> Void)? = nil, onError: ((Error?) -> Void)? = nil) {
        let operation = UseCaseOperation(self, useCase: useCase, errorHandler: errorHandler, includeAllExceptions: includeAllExceptions)
        operation.queuePriority = queuePriority
        operation.finishQueue = finishQueue
        self.onSuccess = onSuccess
        self.onError = onError
        self.operation = operation
        useCaseHandler.execute(operation)
    }
    
    @discardableResult
    init(with useCase: UseCase<Input, Response, Error>, useCaseHandler: UseCaseHandler, errorHandler: UseCaseErrorHandler? = nil, queuePriority: Foundation.Operation.QueuePriority = Foundation.Operation.QueuePriority.normal, finishQueue: UseCaseOperationFinishQueue = .mainThread, onSuccess: ((Response) -> Void)? = nil, onGenericErrorType:  @escaping (UseCaseError<Error>) -> Void) {
        let operation = UseCaseOperation(self, useCase: useCase, errorHandler: errorHandler)
        operation.queuePriority = queuePriority
        operation.finishQueue = finishQueue
        self.onSuccess = onSuccess
        self.onGenericErrorType = onGenericErrorType
        self.operation = operation
        useCaseHandler.execute(operation)
    }
    
    public func cancel() {
        operation?.cancel()
    }
    
    class UseCaseOperation: UseCaseOperationImpl<UseCaseWrapper, Input, Response, Error> {
        override public func onSuccess(result: Response) {
            super.onSuccess(result: result)
            parent.onSuccess?(result)
        }
        
        override public func onError(err: Error) {
            super.onError(err: err)
            parent.onError?(err)
            parent.onGenericErrorType?(UseCaseError.error(err))
        }
        
        override func genericError() {
            super.genericError()
            parent.onGenericErrorType?(.generic)
        }
        
        override func inernalError() {
            super.inernalError()
            parent.onGenericErrorType?(.intern)
        }
        
        override func networkUnavailable() {
            super.networkUnavailable()
            parent.onGenericErrorType?(.networkUnavailable)
        }
    }
    
}

extension UseCaseWrapper: Cancelable {}
