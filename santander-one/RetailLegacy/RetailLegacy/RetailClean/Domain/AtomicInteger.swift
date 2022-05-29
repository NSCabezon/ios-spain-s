import Foundation

class AtomicInteger {
    
    private let lock = DispatchSemaphore(value: 1)
    private var value = 0
    
    // You need to lock on the value when reading it too since
    // there are no volatile variables in Swift as of today.
    func get() -> Int {
        
        lock.wait()
        defer { lock.signal() }
        return value
    }
    
    func set(_ newValue: Int) {
        
        lock.wait()
        defer { lock.signal() }
        value = newValue
    }
    
    func increment() {
        lock.wait()
        defer { lock.signal() }
        value += 1
    }
    
    func incrementAndGet() -> Int {
        
        lock.wait()
        defer { lock.signal() }
        value += 1
        return value
    }
    
    func decrementAndGet() -> Int {
        
        lock.wait()
        defer { lock.signal() }
        value -= 1
        return value
    }
}
