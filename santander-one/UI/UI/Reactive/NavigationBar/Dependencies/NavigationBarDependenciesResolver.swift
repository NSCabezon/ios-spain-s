//
//  NavigationBarDependenciesResolver.swift
//  Commons
//
//  Created by Juan Carlos López Robles on 12/3/21.
//

import Foundation

protocol NavigationBarDependenciesResolver {
    var external: NavigationBarExternalDependenciesResolver { get }
    func resolve() -> NavigationBarViewModel
    func resolve() -> GetBarItemUseCase
    func resolve() -> GlobalSearchUsecase
}

extension NavigationBarDependenciesResolver {
    func resolve() -> NavigationBarViewModel {
        NavigationBarViewModel(dependencies: self)
    }
    
    func resolve() -> GetBarItemUseCase {
        DefaultGetBarItemUseCase(dependencies: self)
    }
    
    func resolve() -> GlobalSearchUsecase {
        DefaultGlobalSearchUsecase(dependencies: self)
    }
}
