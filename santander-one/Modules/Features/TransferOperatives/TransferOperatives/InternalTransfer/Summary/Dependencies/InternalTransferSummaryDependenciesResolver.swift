//
//  InternalTransferSummaryDependenciesResolver.swift
//  Account
//
//  Created by crodrigueza on 4/3/22.
//

import UI
import Foundation
import CoreFoundationLib
import OpenCombine
import CoreDomain

protocol InternalTransferSummaryDependenciesResolver {
    var external: InternalTransferSummaryExternalDependenciesResolver { get }
    func resolve() -> DataBinding
    func resolve() -> InternalTransferOperative
    func resolve() -> InternalTransferSummaryViewModel
    func resolve() -> InternalTransferSummaryViewController
    func resolve() -> InternalTransferOperativeCoordinator
}

extension InternalTransferSummaryDependenciesResolver {
    func resolve() -> InternalTransferSummaryViewController {
        return InternalTransferSummaryViewController(dependencies: self)
    }

    func resolve() -> InternalTransferSummaryViewModel {
        return InternalTransferSummaryViewModel(dependencies: self)
    }
}

struct InternalTransferSummaryDependency: InternalTransferSummaryDependenciesResolver {
    let dependencies: InternalTransferSummaryExternalDependenciesResolver
    let dataBinding: DataBinding
    let coordinator: InternalTransferOperativeCoordinator
    let operative: InternalTransferOperative

    var external: InternalTransferSummaryExternalDependenciesResolver {
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
