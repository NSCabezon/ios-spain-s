//
//  PersonalAreaHomeDependenciesResolver.swift
//  PersonalArea
//
//  Created by alvola on 4/4/22.
//

import Foundation

protocol PersonalAreaHomeDependenciesResolver {
    var external: PersonalAreaHomeExternalDependenciesResolver { get }
    func resolve() -> PersonalAreaHomeViewController
    func resolve() -> PersonalAreaHomeCoordinator
    func resolve() -> PersonalAreaHomeViewModel
}

extension PersonalAreaHomeDependenciesResolver {
    func resolve() -> PersonalAreaHomeViewModel {
        return PersonalAreaHomeViewModel(dependencies: self)
    }
    
    func resolve() -> PersonalAreaHomeViewController {
        return PersonalAreaHomeViewController(dependencies: self)
    }
}
