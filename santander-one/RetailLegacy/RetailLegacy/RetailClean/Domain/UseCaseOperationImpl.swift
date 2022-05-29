import CoreFoundationLib
import SANLegacyLibrary

protocol CustomUseCaseErrorHandler: UseCaseErrorHandler {
   
}

class UseCaseOperationImpl<Parent, Request, Result, Err>: UseCaseOperation<Request, Result, Err>  where Err: StringErrorOutput {
    
    var logTag: String {
        return String(describing: type(of: self))
    }
    
    var parent: Parent
    
    private var includeAllExceptions: Bool

    init (_ parent: Parent, useCase: UseCase<Request, Result, Err>, errorHandler: UseCaseErrorHandler? = nil, includeAllExceptions: Bool = false) {
        self.includeAllExceptions = includeAllExceptions
        self.parent = parent
        super.init(useCase: useCase, errorHandler: errorHandler)
    }
    
    override func onOperationFinished (data: OperationResponse<Result, Err>?) {
        do {
            if let data = data {
                if try data.isOkResult() {
                    onSuccess(result: try data.getOkResult())
                } else {
                    onError(err: try data.getErrorResult())
                }
            } else {
                  throw Exception("operation result nil")
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
            self.genericError()
        }
        
    }    
    
    override func onSuccess(result: Result) {
        super.onSuccess(result: result)
        RetailLogger.i(logTag, "onSuccess -> \(result)")
    }
    
    override func onError(err: Err) {
        super.onError(err: err)
        RetailLogger.e(logTag, "onError -> \(err.getErrorDesc() ?? "")")
    }
    
    func networkUnavailable() {
        RetailLogger.e(logTag, "networkUnavailable")
        errorHandler?.showNetworkUnavailable()
    }
    
    func inernalError() {
        RetailLogger.e(logTag, "genericError")
        errorHandler?.showGenericError()
    }
    
    func genericError() {
        RetailLogger.e(logTag, "genericError")
        errorHandler?.showGenericError()
    }
    
    private func unauthorized() {
        RetailLogger.e(logTag, "unauthorized")
        errorHandler?.unauthorized()
    }
}

class GenericErrorOutput: StringErrorOutput {
}

class NetworkUnavailableErrorOutput: StringErrorOutput {
}

class UnauthorizedErrorOutput: StringErrorOutput {
}

class UseCaseOperationWeakFatherImpl<Parent, Request, Result, Err>: UseCaseOperation<Request, Result, Err>  where Err: StringErrorOutput {
    
    var logTag: String {
        return String(describing: type(of: self))
    }
    
    var parent: Parent
    
    private var includeAllExceptions: Bool

    init (_ parent: Parent, useCase: UseCase<Request, Result, Err>, errorHandler: UseCaseErrorHandler? = nil, includeAllExceptions: Bool = false) {
        self.includeAllExceptions = includeAllExceptions
        self.parent = parent
        super.init(useCase: useCase, errorHandler: errorHandler)
    }
    
    override func onOperationFinished (data: OperationResponse<Result, Err>?) {
        do {
            if let data = data {
                if try data.isOkResult() {
                    onSuccess(result: try data.getOkResult())
                } else {
                    onError(err: try data.getErrorResult())
                }
            } else {
                  throw Exception("operation result nil")
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
            self.genericError()
        }
        
    }
    
    override func onSuccess(result: Result) {
        super.onSuccess(result: result)
        RetailLogger.i(logTag, "onSuccess -> \(result)")
    }
    
    override func onError(err: Err) {
        super.onError(err: err)
        RetailLogger.e(logTag, "onError -> \(err.getErrorDesc() ?? "")")
    }
    
    func networkUnavailable() {
        RetailLogger.e(logTag, "networkUnavailable")
        errorHandler?.showNetworkUnavailable()
    }
    
    func inernalError() {
        RetailLogger.e(logTag, "genericError")
        errorHandler?.showGenericError()
    }
    
    func genericError() {
        RetailLogger.e(logTag, "genericError")
        errorHandler?.showGenericError()
    }
    
    private func unauthorized() {
        RetailLogger.e(logTag, "unauthorized")
        errorHandler?.unauthorized()
    }
}
