//
//  SavingDetailDependenciesResolver.swift
//  SavingProducts
//
//  Created by Marcos Álvarez Mesa on 25/4/22.
//

import CoreFoundationLib
import CoreDomain
import Foundation

protocol SavingDetailDependenciesResolver {
    var external: SavingDetailExternalDependenciesResolver { get }
    func resolve() -> DataBinding
    func resolve() -> SavingDetailViewModel
    func resolve() -> SavingDetailViewController
    func resolve() -> SavingDetailCoordinator
}

extension SavingDetailDependenciesResolver {
    func resolve() -> SavingDetailViewModel {
        return SavingDetailViewModel(dependencies: self)
    }

    func resolve() -> SavingDetailViewController {
        return SavingDetailViewController(dependencies: self)
    }
}
