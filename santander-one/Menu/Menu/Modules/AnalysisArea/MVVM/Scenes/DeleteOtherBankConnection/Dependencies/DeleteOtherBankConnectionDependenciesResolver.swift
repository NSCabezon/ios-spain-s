//
//  DeleteOtherBankConnectionDependenciesResolver.swift
//  Menu
//
//  Created by Adrian Arcalá Ocón on 21/3/22.
//

import UI
import CoreFoundationLib
import Foundation
import OpenCombine
import CoreDomain

protocol DeleteOtherBankConnectionDependenciesResolver {
    var external: DeleteOtherBankConnectionExternalDependenciesResolver { get }
    func resolve() -> DeleteOtherBankConnectionViewModel
    func resolve() -> DeleteOtherBankConnectionViewController
    func resolve() -> DeleteOtherBankConnectionCoordinator
    func resolve() -> DataBinding
    func resolve() -> DeleteOtherBankConnectionUseCase
}

extension DeleteOtherBankConnectionDependenciesResolver {
    
    func resolve() -> DeleteOtherBankConnectionViewController {
        return DeleteOtherBankConnectionViewController(dependencies: self)
    }
    
    func resolve() -> DeleteOtherBankConnectionViewModel {
        return DeleteOtherBankConnectionViewModel(dependencies: self)
    }
    
    func resolve() -> DeleteOtherBankConnectionUseCase {
        return DefaultDeleteOtherBankConnectionUseCase(dependencies: self)
    }
}
