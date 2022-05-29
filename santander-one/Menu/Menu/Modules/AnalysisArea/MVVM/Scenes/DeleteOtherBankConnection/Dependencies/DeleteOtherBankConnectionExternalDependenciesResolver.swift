//
//  DeleteOtherBankConnectionExternalDependenciesResolver.swift
//  Menu
//
//  Created by Adrian Arcalá Ocón on 21/3/22.
//

import UI
import CoreFoundationLib
import Foundation
import OpenCombine
import CoreDomain

public protocol DeleteOtherBankConnectionExternalDependenciesResolver {
    func resolve() -> UINavigationController
    func deleteOtherBankConnectionCoordinator() -> BindableCoordinator
    func resolve() -> FinancialHealthRepository
}

public extension DeleteOtherBankConnectionExternalDependenciesResolver {
    func deleteOtherBankConnectionCoordinator() -> BindableCoordinator {
        return DefaultDeleteOtherBankConnectionCoordinator(dependencies: self, navigationController: resolve())
    }
}
