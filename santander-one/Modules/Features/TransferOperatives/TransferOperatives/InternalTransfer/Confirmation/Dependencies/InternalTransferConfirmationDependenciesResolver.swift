//
//  InternalTransferConfirmationDependenciesResolver.swift
//  TransferOperatives
//
//  Created by Juan Sánchez Marín on 2/3/22.
//

import UI
import Foundation
import CoreFoundationLib
import OpenCombine
import CoreDomain

protocol InternalTransferConfirmationDependenciesResolver {
    var external: InternalTransferConfirmationExternalDependenciesResolver { get }
    func resolve() -> DataBinding
    func resolve() -> InternalTransferOperative
    func resolve() -> InternalTransferConfirmationViewModel
    func resolve() -> InternalTransferConfirmationViewController
    func resolve() -> InternalTransferOperativeCoordinator
}

extension InternalTransferConfirmationDependenciesResolver {
    func resolve() -> InternalTransferConfirmationViewController {
        return InternalTransferConfirmationViewController(dependencies: self)
    }

    func resolve() -> InternalTransferConfirmationViewModel {
        return InternalTransferConfirmationViewModel(dependencies: self)
    }
}

struct InternalTransferConfirmationDependency: InternalTransferConfirmationDependenciesResolver {
    let dependencies: InternalTransferConfirmationExternalDependenciesResolver
    let dataBinding: DataBinding
    let coordinator: InternalTransferOperativeCoordinator
    let operative: InternalTransferOperative

    var external: InternalTransferConfirmationExternalDependenciesResolver {
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
