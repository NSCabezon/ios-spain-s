//
//  OneFavouritesListDependenciesResolver.swift
//  Transfer
//
//  Created by Carlos Monfort Gómez on 4/1/22.
//

import CoreFoundationLib
import OpenCombine
import CoreDomain
import UI

protocol OneFavouritesListDependenciesResolver {
    var external: OneFavouritesListExternalDependenciesResolver { get }
    func resolve() -> OneFavouritesListViewModel
    func resolve() -> OneFavouritesListViewController
    func resolve() -> OneFavouritesListCoordinator
    func resolve() -> DataBinding
}

extension OneFavouritesListDependenciesResolver {
    func resolve() -> OneFavouritesListViewModel {
        return OneFavouritesListViewModel(dependencies: self)
    }
    
    func resolve() -> OneFavouritesListViewController {
        return OneFavouritesListViewController(dependencies: self)
    }
}
