import Foundation

open class UseCaseHandler: NSObject {
    private let manager: ThreadSafeProperty<OperationQueue>
    
    public init(maxConcurrentOperationCount: Int = 8, qualityOfService: QualityOfService = .userInitiated) {
        self.manager = ThreadSafeProperty(OperationQueue())
        self.manager.value.maxConcurrentOperationCount = maxConcurrentOperationCount
        self.manager.value.qualityOfService = qualityOfService
        super.init()
    }
    
    private var threadSafeObservableCount: ThreadSafeProperty<Int> = ThreadSafeProperty(0)

    @objc dynamic public var observableCount: Int {
        get {
            self.threadSafeObservableCount.value
        }
        set {
            self.threadSafeObservableCount.value = newValue
        }
    }
    
    public var operationCount: Int {
        return manager.value.operationCount
    }
    
    open func execute<Request, Result, Err>(_ operation: UseCaseOperation<Request, Result, Err>) {
        manager.value.addOperation(operation)
        observableCount += 1
    }
    
    public func stopAll() {
        manager.value.cancelAllOperations()
    }
    
    public func stop<Request, Result, Err>(_ callback: UseCaseOperation<Request, Result, Err>) {
        callback.cancel()
    }
    
    public func waitUntilAllOperationsAreFinished() {
        manager.value.waitUntilAllOperationsAreFinished()
    }
    
    public func pause() {
        manager.value.isSuspended = true
    }
    
    public func resume() {
        manager.value.isSuspended = false
    }
}
