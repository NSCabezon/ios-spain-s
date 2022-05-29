//
//  File.swift
//  Pods
//
//  Created by Juan Carlos López Robles on 11/20/20.
//

import Foundation

public protocol PublicFilesManagerProtocol {
    func loadPublicFiles(withStrategy strategy: PublicFilesStrategyType, timeout: TimeInterval)
    func cancelPublicFilesLoad(withStrategy strategy: PublicFilesStrategyType)
    func remove<T>(subscriptor type: T.Type)
    func loadPublicFiles<T>(addingSubscriptor type: T.Type, withStrategy strategy: PublicFilesStrategyType, timeout: TimeInterval, subscriptorActionBlock: @escaping () -> Void)
    func add<T>(subscriptor type: T.Type, subscriptorActionBlock: @escaping () -> Void)
}
