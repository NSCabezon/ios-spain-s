import CoreFoundationLib
import Foundation

class SecondaryUseCaseHandler: UseCaseHandler {
    
    private let main: UseCaseHandler
    private let keyPathToObserve = #keyPath(UseCaseHandler.observableCount)
    private var isObserver = ThreadSafeProperty(false)
    private let semaphore = DispatchSemaphore(value: 1)
    
    deinit {
        removeObserver()
    }
    
    init(main: UseCaseHandler, maxConcurrentOperationCount: Int = 8, qualityOfService: QualityOfService = .userInitiated) {
        self.main = main
        super.init(maxConcurrentOperationCount: maxConcurrentOperationCount, qualityOfService: qualityOfService)
        addObserver()
    }
    
    private func addObserver() {
        defer {
            semaphore.signal()
        }
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        guard !isObserver.value else { return }
        isObserver.value = true
        main.addObserver(self, forKeyPath: keyPathToObserve, options: NSKeyValueObservingOptions.new, context: nil)
    }
    
    private func removeObserver() {
        defer {
            semaphore.signal()
        }
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        guard isObserver.value else { return }
        isObserver.value = false
        main.removeObserver(self, forKeyPath: keyPathToObserve)
    }
    
    // swiftlint:disable block_based_kvo
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        DispatchQueue.global(qos: .background).async {
            if keyPath == self.keyPathToObserve, self.main.operationCount > 0, self.isObserver.value {
                self.removeObserver()
                self.pause()
                self.main.waitUntilAllOperationsAreFinished()
                self.addObserver()
                self.resume()
            }
        }
    }
    // swiftlint:enable block_based_kvo
}
