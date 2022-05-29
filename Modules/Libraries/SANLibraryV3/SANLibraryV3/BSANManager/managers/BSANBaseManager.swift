import CoreDomain
import Foundation

public class BSANBaseManager {

    static var serviceNameLanguage: ServiceNameLanguage?
    private let requestSemaphores = RequestSemaphores()
    
    var logTag: String {
        return String(describing: type(of: self))
    }

    let bsanDataProvider: BSANDataProvider

    public init(bsanDataProvider: BSANDataProvider) {
        self.bsanDataProvider = bsanDataProvider
    }

    internal func generateDateFilter() -> DateFilter {
        let dateFilter = DateFilter()

        var dateComponent = DateComponents()
        dateComponent.year = -1
        let date = Date()
        dateFilter.fromDateModel = DateModel(date: Calendar.current.date(byAdding: dateComponent, to: date) ?? date)
        dateFilter.toDateModel = DateModel(date: date)

        return dateFilter
    }
}

extension BSANBaseManager {
    
    /// Method to avoid multiple-calls to the same request at the same time. It creates a semaphore with an identifier for each "functionName + key".
    /// - Parameters:
    ///   - functionName: The functionName of the caller
    ///   - key: The uniqueKey to identify the semaphore (for example, you can use an Account)
    ///   - requestBlock: Block to perform the network request.
    func syncronizeRequest<Response>(
        for functionName: String = #function,
        by key: String,
        requestBlock: () throws -> BSANResponse<Response>
    ) throws -> BSANResponse<Response> {
        let semaphoreKey = functionName + key
        self.wait(for: semaphoreKey)
        defer {
            self.signal(for: semaphoreKey)
        }
        return try requestBlock()
    }
}

private extension BSANBaseManager {
    
    func wait(for request: String) {
        self.requestSemaphores.wait(for: request)
    }
    
    func signal(for request: String) {
        self.requestSemaphores.signal(for: request)
    }
}

private class RequestSemaphores {
    
    // A semaphore to set `requestSemaphores` a thread safe property
    private let threadSafeSemaphore = DispatchSemaphore(value: 1)
    // A dictionary with a semaphore for each request
    private var requestSemaphores: [String: DispatchSemaphore] = [:]
    
    func wait(for request: String) {
        self.threadSafeAction {
            if self.requestSemaphores[request] == nil {
                self.requestSemaphores[request] = DispatchSemaphore(value: 1)
            }
            self.requestSemaphores[request]?.wait()
        }
    }
    
    func signal(for request: String) {
        self.threadSafeAction {
            self.requestSemaphores[request]?.signal()
        }
    }
    
    private func threadSafeAction(completion: () -> Void) {
        self.threadSafeSemaphore.wait(wallTimeout: .now() + 0.01)
        completion()
        self.threadSafeSemaphore.signal()
    }
}
