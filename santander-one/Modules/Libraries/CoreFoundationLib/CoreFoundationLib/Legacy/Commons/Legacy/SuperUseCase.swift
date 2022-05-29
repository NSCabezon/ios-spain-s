import Foundation

public protocol SuperUseCaseDelegate: AnyObject {
    func onSuccess()
    func onError(error: String?)
}

open class SuperUseCase<Delegate: SuperUseCaseDelegate> {
    
    // MARK: - Private
    
    private let useCaseHandler: UseCaseHandler
    private lazy var dispatchGroup: DispatchGroup = {
        return DispatchGroup()
    }()
    private let semaphore = DispatchSemaphore(value: 1)
    private weak var delegate: Delegate?
    private var tasks: [WeakReference<Cancelable>] = []
    
    // MARK: - Public
    
    public init(useCaseHandler: UseCaseHandler, delegate: Delegate? = nil) {
        self.useCaseHandler = useCaseHandler
        self.delegate = delegate
    }
    
    /// Add a use to be performed
    ///
    /// - Parameters:
    ///   - useCase: the use case
    ///   - mandatory: if the use case is mandatory (if it fails, the SuperUseCase will fail)
    ///   - onSuccess: a closure where you can manage the result of the use case
    public func add<Request, Result, Error>(_ useCase: UseCase<Request, Result, Error>, isMandatory mandatory: Bool = true, onSuccess: ((Result) -> Void)? = nil) {
        dispatchGroup.enter()
        let task = UseCaseWrapper(
            with: useCase,
            useCaseHandler: useCaseHandler,
            onSuccess: { [weak self] result in
                self?.semaphore.wait()
                onSuccess?(result)
                self?.semaphore.signal()
                self?.dispatchGroup.leave()
            },
            onError: { [weak self] error in
                if mandatory {
                    self?.cancelAllWithError(error: error.getErrorDesc())
                } else {
                    self?.dispatchGroup.leave()
                }
            }
        )
        self.tasks.append(WeakReference(reference: task))
    }
    
    public func cancel() {
        self.tasks.forEach { $0.reference?.cancel() }
        self.tasks.removeAll(where: { $0.reference == nil })
    }
    
    /// Perform this method to execute the SuperUseCase
    public final func execute() {
        self.dispatchGroup = DispatchGroup()
        self.setupUseCases()
        self.dispatchGroup.notify(queue: DispatchQueue.main) { [weak self] in
            self?.delegate?.onSuccess()
        }
    }
    
    // Method that must be overrided (don't call to super.setupUseCases())
    open func setupUseCases() {
        fatalError()
    }
    
    // MARK: - Private methods
    
    private func cancelAllWithError(error: String?) {
        self.cancel()
        self.delegate?.onError(error: error)
    }
}

extension SuperUseCase {
    public typealias VoidFunction = () -> Void

    /**
         Submits a work to a dispatch group for asynchronous execution. The work become part of the super use case either adding with this method or add<Request, Result, Error>(...
         - Parameter work: this is the work to be executed
         
         - Important: call completion once the work you submit its intended to be finished
         ~~~
         self.add { completion in
             DispatchQueue.main.asyncAfter(deadline: .now() + 15.0) {
                 for numbers in 1...50 {
                     print("\(numbers)")
                 }
                 completion()
             }
         }
         ~~~
     */
    public func add(work: @escaping (_ completion: @escaping VoidFunction) -> Void) {
        self.dispatchGroup.enter()
        work {
            self.dispatchGroup.leave()
        }
    }
}
