//
//  CoreRepositoriesDependenciesResolver.swift
//  CoreFoundationLib
//
//  Created by Jose Ignacio de Juan Díaz on 26/1/22.
//

import CoreDomain

public protocol UserPreferencesDependenciesResolver: CoreDependenciesResolver {
    func resolve() -> UserPreferencesRepository
}
