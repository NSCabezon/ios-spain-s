import SANLegacyLibrary

public protocol CustomUseCaseErrorHandler: UseCaseErrorHandler {
    
}

open class UseCaseOperationImpl<Parent, Request, Result, Err>: UseCaseOperation<Request, Result, Err>  where Err: StringErrorOutput {
    public let parent: Parent
    
    public init (_ parent: Parent, useCase: UseCase<Request, Result, Err>) {
        self.parent = parent
        super.init(useCase: useCase, errorHandler: nil)
    }
    
    override public func onOperationFinished (data: OperationResponse<Result, Err>?) {
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
            self.networkUnavailable()
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
            self.genericError()
        }
    }
    
    public func networkUnavailable() {
    }
    
    public func inernalError() {
    }
    
    public func genericError() {
    }
    
    private func illegalState() {
    }
    
    public func unauthorized() {
    }
}

public class GenericErrorOutput: StringErrorOutput {
}

public class NetworkUnavailableErrorOutput: StringErrorOutput {
}

public class UnauthorizedErrorOutput: StringErrorOutput {
}

open class UseCaseOperationWeakFatherImpl<Parent: AnyObject, Request, Result, Err>: UseCaseOperation<Request, Result, Err>  where Err: StringErrorOutput {
    public weak var parent: Parent?
    
    public init (_ parent: Parent, useCase: UseCase<Request, Result, Err>) {
        self.parent = parent
        super.init(useCase: useCase, errorHandler: nil)
    }
    
    override public func onOperationFinished (data: OperationResponse<Result, Err>?) {
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
            self.networkUnavailable()
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
            self.genericError()
        }
    }
    
    public func networkUnavailable() {
    }
    
    public func inernalError() {
    }
    
    public func genericError() {
    }
    
    private func illegalState() {
    }
    
    public func unauthorized() {
    }
}
