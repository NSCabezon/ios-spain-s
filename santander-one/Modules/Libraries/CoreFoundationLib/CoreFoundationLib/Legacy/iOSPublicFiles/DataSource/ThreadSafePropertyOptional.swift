import Foundation

class ThreadSafePropertyOptional<T> {
    private var _property: T?
    private let semaphore: DispatchSemaphore
    
    var value: T? {
        get {
            let result: T?
            self.semaphore.wait()
            result = _property
            self.semaphore.signal()
            return result
        }
        set {
            self.semaphore.wait()
            self._property = newValue
            self.semaphore.signal()
        }
    }
    
    init() {
        self.semaphore = DispatchSemaphore(value: 1)
    }
}
