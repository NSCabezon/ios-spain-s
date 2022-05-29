//
//  InternalTransferAccountSelectorDependenciesResolver.swift
//  TransferOperatives
//
//  Created by Cristobal Ramos Laina on 7/2/22.
//

import UI
import Foundation
import CoreFoundationLib
import OpenCombine
import CoreDomain

protocol InternalTransferAccountSelectorDependenciesResolver {
    var external: InternalTransferAccountSelectorExternalDependenciesResolver { get }
    func resolve() -> DataBinding
    func resolve() -> InternalTransferOperative
    func resolve() -> InternalTransferAccountSelectorViewModel
    func resolve() -> InternalTransferAccountSelectorViewController
    func resolve() -> InternalTransferOperativeCoordinator
}

extension InternalTransferAccountSelectorDependenciesResolver {
    
    func resolve() -> InternalTransferAccountSelectorViewController {
        return InternalTransferAccountSelectorViewController(dependencies: self)
    }
    
    func resolve() -> InternalTransferAccountSelectorViewModel {
        return InternalTransferAccountSelectorViewModel(dependencies: self)
    }
}

struct InternalTransferAccountSelectorDependency: InternalTransferAccountSelectorDependenciesResolver {
    let dependencies: InternalTransferAccountSelectorExternalDependenciesResolver
    let dataBinding: DataBinding
    let coordinator: InternalTransferOperativeCoordinator
    let operative: InternalTransferOperative
    
    var external: InternalTransferAccountSelectorExternalDependenciesResolver {
        return dependencies
    }
    
    func resolve() -> InternalTransferOperativeCoordinator {
        return coordinator
    }
    
    func resolve() -> DataBinding {
        return dataBinding
    }
    
    func resolve() -> InternalTransferOperative {
        return operative
    }
}

