//
//  SessionDataManagerMock.swift
//  ExampleApp
//
//  Created by Jose Camallonga on 13/12/21.
//

import Foundation
import OpenCombine
import CoreFoundationLib

public final class SessionDataManagerMock: SessionDataManager {
    private weak var dataManagerDelegate: SessionDataManagerDelegate?
    private weak var dataManagerProcessDelegate: SessionDataManagerProcessDelegate?
    private let eventSubject = PassthroughSubject<SessionManagerProcessEvent, Error>()
    
    public init() {}
    
    public var event: AnyPublisher<SessionManagerProcessEvent, Error> {
        self.eventSubject.eraseToAnyPublisher()
    }
    
    public func load() {
        dataManagerDelegate?.willLoadSession()
        sendEvent(.loadDataSuccess)
    }
    
    public func cancel() {
        sendEvent(.cancelByUser)
    }
    
    public func setDataManagerDelegate(_ delegate: SessionDataManagerDelegate?) {
        self.dataManagerDelegate = delegate
    }
    
    public func setDataManagerProcessDelegate(_ delegate: SessionDataManagerProcessDelegate?) {
        self.dataManagerProcessDelegate = delegate
    }
    
    public func loadPublisher() -> AnyPublisher<Void, Error> {
        return Empty()
            .eraseToAnyPublisher()
    }
}

private extension SessionDataManagerMock {
    func sendEvent(_ event: SessionManagerProcessEvent) {
        dataManagerProcessDelegate?.handleProcessEvent(event)
    }
}
