//
//  ShareDependenciesResolver.swift
//  Alamofire
//
//  Created by Juan Carlos López Robles on 11/11/21.
//

import Foundation

public protocol ShareDependenciesResolver {
    func resolve() -> UINavigationController
    func resolve() -> ShareCoordinator
    func resolve() -> SharedHandler
}

public extension ShareDependenciesResolver {
    
    func resolve() -> ShareCoordinator {
        return DefaultShareCoordinator(dependencies: self, navigationController: resolve())
    }
    
    func resolve() -> SharedHandler {
        return SharedHandler()
    }
}
