import Foundation
import CoreFoundationLib
import SANLegacyLibrary

enum SuperUseCaseResult<Result, Error> {
    case success(Result)
    case error(Error)
}

protocol SuperUseCaseDelegate: AnyObject {
    func onSuccess()
    func onError(error: String?)
}

class SuperUseCase<Delegate: SuperUseCaseDelegate, ErrorHandler: UseCaseErrorHandler> {
    
    // MARK: - Private
    
    private let useCaseHandler: UseCaseHandler
    private let errorHandler: ErrorHandler
    private var dispatchGroup = ThreadSafeProperty(DispatchGroup())
    private let semaphore = DispatchSemaphore(value: 1)
    private let queuePriority: Foundation.Operation.QueuePriority
    private let finishQueue: UseCaseOperationFinishQueue
    private weak var delegate: Delegate?
    private var timer: ThreadSafeProperty<Timer>?
    private var tasks: [WeakReference<Cancelable>] = []
    
    // MARK: - Public
    
    let useCaseProvider: UseCaseProvider
    
    init(useCaseProvider: UseCaseProvider, useCaseHandler: UseCaseHandler, errorHandler: ErrorHandler, delegate: Delegate? = nil, queuePriority: Foundation.Operation.QueuePriority = .normal, finishQueue: UseCaseOperationFinishQueue = .mainThread) {
        self.useCaseProvider = useCaseProvider
        self.useCaseHandler = useCaseHandler
        self.errorHandler = errorHandler
        self.delegate = delegate
        self.queuePriority = queuePriority
        self.finishQueue = finishQueue
    }
    
    /// Add a use to be performed
    ///
    /// - Parameters:
    ///   - useCase: the use case
    ///   - mandatory: if the use case is mandatory (if it fails, the SuperUseCase will fail)
    ///   - onSuccess: a closure where you can manage the result of the use case
    func add<Request, Result, Error>(_ useCase: UseCase<Request, Result, Error>, isMandatory mandatory: Bool = true, onSuccess: ((Result) -> Void)? = nil) {
        dispatchGroup.value.enter()
        let task: Cancelable
        if mandatory {
            task = UseCaseWrapper(
                with: useCase,
                useCaseHandler: useCaseHandler,
                errorHandler: errorHandler,
                queuePriority: queuePriority,
                finishQueue: finishQueue,
                onSuccess: { [weak self] result in
                    self?.semaphore.wait()
                    onSuccess?(result)
                    self?.semaphore.signal()
                    self?.dispatchGroup.value.leave()
                },
                onError: { [weak self] error in
                    self?.cancelAllWithError(error: error)
                }
            )
        } else {
            task = UseCaseWrapper(
                with: useCase,
                useCaseHandler: useCaseHandler,
                errorHandler: nil,
                queuePriority: queuePriority,
                finishQueue: finishQueue,
                onSuccess: { [weak self] result in
                    self?.semaphore.wait()
                    onSuccess?(result)
                    self?.semaphore.signal()
                    self?.dispatchGroup.value.leave()
                },
                onError: { [weak self] _ in
                    self?.dispatchGroup.value.leave()
                }
            )
        }
        self.tasks.append(WeakReference(reference: task))
    }
    
    func cancel() {
        self.tasks.forEach { $0.reference?.cancel() }
        self.tasks.removeAll(where: { $0.reference == nil })
    }
    
    /// Perform this method to execute the SuperUseCase
    final func execute() {
        execute { [weak self] in
            self?.delegate?.onSuccess()
        }
    }
    
    final func execute(withTimeout timeout: TimeInterval) {
        let timer = Timer.scheduledTimer(withTimeInterval: timeout, repeats: false) { [weak self] _ in
            guard self?.timer?.value.isValid == true else { return }
            self?.cancel()
            self?.timer?.value.invalidate()
            self?.delegate?.onError(error: nil)
        }
        self.timer = ThreadSafeProperty(timer)
        execute { [weak self] in
            guard self?.timer?.value.isValid == true else { return }
            self?.timer?.value.invalidate()
            self?.delegate?.onSuccess()
        }
    }
    
    // Method that must be overrided (don't call to super.setupUseCases())
    func setupUseCases() {
        fatalError()
    }
    
    // MARK: - Private methods
    
    private func execute(onSuccess: @escaping () -> Void) {
        self.dispatchGroup = ThreadSafeProperty(DispatchGroup())
        self.setupUseCases()
        self.dispatchGroup.value.notify(queue: DispatchQueue.main, execute: onSuccess)
    }
    
    private func cancelAllWithError(error: StringErrorOutput?) {
        self.cancel()
        self.delegate?.onError(error: error?.getErrorDesc())
    }
}
