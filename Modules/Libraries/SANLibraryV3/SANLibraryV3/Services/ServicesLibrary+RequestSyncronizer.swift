//
//  ServicesLibrary+RequestSyncronizer.swift
//  SANServicesLibrary
//
//  Created by José Carlos Estela Anguita on 12/5/21.
//

import CoreDomain
import SANServicesLibrary

extension ServicesLibrary: RequestSyncronizer {
    public func syncronizeRequest<Response>(
        for functionName: String = #function,
        by key: String,
        requestBlock: () -> Result<Response, Error>
    ) -> Result<Response, Error> {
        let semaphoreKey = functionName + key
        self.wait(for: semaphoreKey)
        defer {
            self.signal(for: semaphoreKey)
        }
        return requestBlock()
    }
}

private extension ServicesLibrary {
    func wait(for request: String) {
        self.requestSemaphores.wait(for: request)
    }
    
    func signal(for request: String) {
        self.requestSemaphores.signal(for: request)
    }
}

class SANRequestSemaphores {
    
    // A semaphore to set `requestSemaphores` a thread safe property
    private let threadSafeSemaphore = DispatchSemaphore(value: 1)
    // A dictionary with a semaphore for each request
    private var requestSemaphores: [String: DispatchSemaphore] = [:]
    
    init() { }
    
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
