//
//  PublicFilesManagerProtocolMock.swift
//  QuickSetup
//
//  Created by Jose Camallonga on 13/12/21.
//

import Foundation
import CoreFoundationLib

public final class PublicFilesManagerProtocolMock: PublicFilesManagerProtocol {
    public init() {}
    
    public func loadPublicFiles(withStrategy strategy: PublicFilesStrategyType, timeout: TimeInterval) {}
    
    public func cancelPublicFilesLoad(withStrategy strategy: PublicFilesStrategyType) {}
    
    public func remove<T>(subscriptor type: T.Type) {}
    
    public func loadPublicFiles<T>(addingSubscriptor type: T.Type,
                                   withStrategy strategy: PublicFilesStrategyType,
                                   timeout: TimeInterval,
                                   subscriptorActionBlock: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            subscriptorActionBlock()
        }
    }
    
    public func add<T>(subscriptor type: T.Type, subscriptorActionBlock: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            subscriptorActionBlock()
        }
    }
}
