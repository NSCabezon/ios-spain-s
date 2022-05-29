//
//  InternalTransferDestinationAccountDependenciesResolver.swift
//  TransferOperatives
//
//  Created by Carlos Monfort Gómez on 15/2/22.
//

import CoreFoundationLib
import OpenCombine
import CoreDomain
import UI

protocol InternalTransferDestinationAccountDependenciesResolver {
    var external: InternalTransferDestinationAccountExternalDependenciesResolver { get }
    func resolve() -> DataBinding
    func resolve() -> InternalTransferOperative
    func resolve() -> InternalTransferDestinationAccountViewModel
    func resolve() -> InternalTransferDestinationAccountViewController
    func resolve() -> InternalTransferOperativeCoordinator
}

extension InternalTransferDestinationAccountDependenciesResolver {
    func resolve() -> InternalTransferDestinationAccountViewController {
        return InternalTransferDestinationAccountViewController(dependencies: self)
    }
    
    func resolve() -> InternalTransferDestinationAccountViewModel {
        return InternalTransferDestinationAccountViewModel(dependencies: self)
    }
}

struct InternalTransferDestinationAccountDependency: InternalTransferDestinationAccountDependenciesResolver {
    let dependencies: InternalTransferDestinationAccountExternalDependenciesResolver
    let dataBinding: DataBinding
    let coordinator: InternalTransferOperativeCoordinator
    let operative: InternalTransferOperative
    
    var external: InternalTransferDestinationAccountExternalDependenciesResolver {
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
