//
//  InternalTransferAmountDependenciesResolver.swift
//  TransferOperatives
//
//  Created by Marcos Álvarez Mesa on 15/2/22.
//

import UI
import Foundation
import CoreFoundationLib
import OpenCombine
import CoreDomain

protocol InternalTransferAmountDependenciesResolver {
    var external: InternalTransferAmountExternalDependenciesResolver { get }
    func resolve() -> DataBinding
    func resolve() -> InternalTransferOperative
    func resolve() -> InternalTransferAmountViewModel
    func resolve() -> InternalTransferAmountViewController
    func resolve() -> InternalTransferOperativeCoordinator
}

extension InternalTransferAmountDependenciesResolver {
    func resolve() -> InternalTransferAmountViewController {
        return InternalTransferAmountViewController(dependencies: self)
    }

    func resolve() -> InternalTransferAmountViewModel {
        return InternalTransferAmountViewModel(dependencies: self)
    }

    func resolve() -> InternalTransferAmountModifierProtocol {
        guard let modifier: InternalTransferAmountModifierProtocol = external.resolve() else {
            return DefaultInternalTransferAmountModifier()
        }
        return modifier
    }
}

struct InternalTransferAmountDependency: InternalTransferAmountDependenciesResolver {
    let dependencies: InternalTransferAmountExternalDependenciesResolver
    let dataBinding: DataBinding
    let coordinator: InternalTransferOperativeCoordinator
    let operative: InternalTransferOperative

    var external: InternalTransferAmountExternalDependenciesResolver {
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

