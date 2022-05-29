//
//  CoreSessionManagerMock.swift
//  ExampleApp
//
//  Created by Jose Camallonga on 13/12/21.
//

import Foundation
import CoreFoundationLib

public final class CoreSessionManagerMock: CoreSessionManager {
    public var isSessionActive: Bool = true
    public var lastFinishedSessionReason: SessionFinishedReason? = nil
    public var configuration: SessionConfiguration = .init(timeToExpireSession: 0,
                                                           timeToRefreshToken: nil,
                                                           sessionStartedActions: [],
                                                           sessionFinishedActions: [])
    
    public init() {}
    
    public func setLastFinishedSessionReason(_ reason: SessionFinishedReason) {}
    
    public func finishWithReason(_ reason: SessionFinishedReason) {}
    
    public func sessionStarted(completion: (() -> Void)?) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            completion?()
        }
    }
}
