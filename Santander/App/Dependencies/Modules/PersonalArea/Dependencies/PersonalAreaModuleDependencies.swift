//
//  PersonalAreaModuleDependencies.swift
//  Santander
//
//  Created by alvola on 18/4/22.
//

import Foundation
import PersonalArea
import UI
import CoreFoundationLib
    
extension ModuleDependencies: PersonalAreaExternalDependenciesResolver {
    
    func resolve() -> GetPersonalAreaHomeConfigurationUseCase {
        return SpainGetPersonalAreaHomeConfigurationUseCase()
    }
    
    func resolve() -> GetHomeUserPreferencesUseCase {
        return SpainGetHomeUserPreferencesUseCase(dependencies: self)
    }
    
    func personalAreaCustomActionCoordinator() -> BindableCoordinator {
        return ToastCoordinator()
    }
    
    func resolve() -> EmmaTrackEventListProtocol {
        let oldResolver: DependenciesResolver = resolve()
        return oldResolver.resolve()
    }
}
