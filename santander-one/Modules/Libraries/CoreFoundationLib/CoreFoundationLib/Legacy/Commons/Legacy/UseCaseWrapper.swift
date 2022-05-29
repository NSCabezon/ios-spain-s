import Foundation
import SANLegacyLibrary
import CoreDomain

public enum UseCaseError<T: StringErrorOutput>: Error {
    case error(_ error: T?)
    case generic
    case intern
    case networkUnavailable
    case unauthorized
    
    public func getErrorDesc() -> String? {
        switch self {
        case .error(error: let errorString):
            return errorString?.getErrorDesc()
        default:
            return nil
        }
    }
}

public class UseCaseWrapper<Input, Response, Error: StringErrorOutput> {
    var onSuccess: ((Response) -> Void)?
    var onError: ((UseCaseError<Error>) -> Void)?
    private weak var operation: UseCaseOperation?
    
    @discardableResult
    public init(with useCase: UseCase<Input, Response, Error>, useCaseHandler: UseCaseHandler, queuePriority: Foundation.Operation.QueuePriority = Foundation.Operation.QueuePriority.normal, onSuccess: ((Response) -> Void)? = nil, onError: ((UseCaseError<Error>) -> Void)? = nil) {
        let operation = UseCaseOperation(self, useCase: useCase)
        operation.queuePriority = queuePriority
        self.onSuccess = onSuccess
        self.onError = onError
        self.operation = operation
        useCaseHandler.execute(operation)
    }
    
    public func cancel() {
        operation?.cancel()
    }

    class UseCaseOperation: CoreFoundationLib.UseCaseOperation<Input, Response, Error> {
        let parent: UseCaseWrapper
        
        public init (_ parent: UseCaseWrapper, useCase: UseCase<Input, Response, Error>) {
            self.parent = parent
            super.init(useCase: useCase, errorHandler: nil)
        }
        
        override public func onOperationFinished (data: OperationResponse<Response, Error>?) {
            do {
                if let data = data {
                    if try data.isOkResult() {
                        onSuccess(result: try data.getOkResult())
                    } else {
                        onError(err: try data.getErrorResult())
                    }
                } else {
                      throw CoreFoundationLib.Exception("operation result nil")
                }
            } catch is WSUnauthorizedException {
                self.unauthorized()
            } catch is BSANUnauthorizedException {
                self.unauthorized()
            } catch is NetworkUnavailableException {
                self.networkUnavailable()
            } catch is BSANNetworkException {
                networkUnavailable()
            } catch is BSANIllegalStateException {
                self.inernalError()
            } catch is RepositoryException {
                self.genericError()
            } catch is BSANServiceException {
                self.genericError()
            } catch is BSANServiceNoImplemented {
                self.inernalError()
            } catch is UserInterruptedException {
                // thread interrupted
                // do nothing
            } catch {
                if let coreException = error as? CoreExceptions {
                    self.handleCoreException(coreException)
                } else {
                    self.genericError()
                }
            }
        }
        
        override public func onSuccess(result: Response) {
            parent.onSuccess?(result)
        }
        
        override public func onError(err: Error) {
            parent.onError?(.error(err))
        }
        
        private func genericError() {
            parent.onError?(.generic)
        }

        private func inernalError() {
            parent.onError?(.intern)
        }
        
        private func networkUnavailable() {
            parent.onError?(.networkUnavailable)
        }
        
        private func unauthorized() {
            parent.onError?(.unauthorized)
        }
        
        private func handleCoreException(_ exception: CoreExceptions) {
            switch exception {
            case .network: self.networkUnavailable()
            case .unauthorized: self.unauthorized()
            }
        }
    }
    
}

extension UseCaseWrapper: Cancelable {}
