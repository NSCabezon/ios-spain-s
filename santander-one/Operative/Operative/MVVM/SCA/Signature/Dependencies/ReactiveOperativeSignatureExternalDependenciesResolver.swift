//
//  ReactiveOperativeSignatureExternalDependenciesResolver.swift
//  Operative
//
//  Created by David Gálvez Alonso on 8/3/22.
//

import CoreFoundationLib

public protocol ReactiveOperativeSignatureExternalDependenciesResolver {
    func resolve() -> UINavigationController
    func resolve() -> DependenciesResolver
    func resolve() -> DataBinding
    func resolve() -> SignatureViewModelProtocol
    func resolve() -> ReactiveOperativeSignatureViewController
    func resolve() -> OperativeCoordinator
}

public extension ReactiveOperativeSignatureExternalDependenciesResolver {
    func resolve() -> ReactiveOperativeSignatureViewController {
        return ReactiveOperativeSignatureViewController(dependencies: self)
    }
}
