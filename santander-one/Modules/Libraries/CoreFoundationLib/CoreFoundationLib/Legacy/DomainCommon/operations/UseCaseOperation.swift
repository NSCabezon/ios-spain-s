import Foundation

public protocol UseCaseErrorHandler {
    
    func unauthorized()
    
    func showNetworkUnavailable()
    
    func showGenericError()
}

public enum UseCaseOperationFinishQueue {
    case mainThread
    case noChange
}

open class UseCaseOperation<Request, Result, Err>: Foundation.Operation where Err: StringErrorOutput {
    
    private enum UseCaseState {
        case ready
        case running
        case delivered
        case interrupted
    }
    
    override open var isAsynchronous: Bool {
        return true
    }
    
    private var useCase: UseCase<Request, Result, Err>
    public var errorHandler: UseCaseErrorHandler?
    private var state: UseCaseState = .ready
    public var finishQueue: UseCaseOperationFinishQueue = .mainThread
    
    public init(useCase: UseCase<Request, Result, Err>, errorHandler: UseCaseErrorHandler? = nil) {
        self.useCase = useCase
        self.errorHandler = errorHandler
        super.init()
    }
    
    public func setErrorHandler(_ errorHandler: UseCaseErrorHandler) {
        self.errorHandler = errorHandler
    }
    
    public func setRequest(_ request: Request) {
        let _ = self.useCase.setRequestValues(requestValues: request)
    }
    
    private func runInBackground() -> OperationResponse<Result, Err>? {
        var pendingResult: OperationResponse<Result, Err>?
        state = .running
        do {
            let useCaseResponse = try useCase.run()
            pendingResult = OperationResponse(useCaseResponse)
        } catch let exception {
            if (state == .interrupted) {
                // Thread interrupted. Data threw a NetworkException but the cause was a InterruptedIOException
                return OperationResponse(UserInterruptedException(exception.localizedDescription))
            }
            // Generic error
            pendingResult = OperationResponse(exception)
        }
        return pendingResult
    }
    
    public func isRunning() -> Bool {
        return state == .running
    }
    
    open override func main() {
        let result = self.runInBackground()
        guard !self.isCancelled else {
            return
        }
        self.state = .delivered
        switch finishQueue {
        case .mainThread:
            DispatchQueue.main.async {
                self.onOperationFinished(data: result)
            }
        case .noChange:
            self.onOperationFinished(data: result)
        }
    }
    
    override open func cancel() {
        super.cancel()
        state = .interrupted
    }
    
    
    open func onOperationFinished(data: OperationResponse<Result, Err>?) {
        fatalError()
    }
    
    open func onSuccess(result: Result) {
    
    }
    
    open func onError(err: Err) {
    
    }
    
}
