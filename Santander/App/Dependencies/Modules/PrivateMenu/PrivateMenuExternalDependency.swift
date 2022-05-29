//
//  PrivateMenuExternalDependency.swift
//  Santander
//
//  Created by Boris Chirino Fernandez on 4/2/22.
//

import UI
import CoreDomain
import Foundation
import RetailLegacy
import CoreFoundationLib
import PrivateMenu

extension ModuleDependencies: PrivateMenuModuleExternalDependenciesResolver {
    
    func resolve() -> GetPrivateMenuFooterOptionsUseCase {
        return ESPrivateMenuFooterOptionsUseCase(dependency: self)
    }
    
    func resolve() -> GetPrivateMenuOptionsUseCase {
        return ESPrivateMenuOptionsUseCase(dependencies: self)
    }
    
    func resolve() -> PersonalManagerReactiveRepository {
        oldResolver.resolve()
    }
    
    func resolve() -> PersonalManagerNotificationReactiveRepository {
        oldResolver.resolve()
    }
    
    func resolve() -> GetPersonalManagerUseCase {
        return ESGetPersonalManagerUseCase(dependencies: self)
    }

    func resolve() -> PrivateMenuToggleOutsider {
        self.drawer
    }
    
    func resolve() -> GetOtherServicesSubMenuUseCase {
        return ESPrivateMenuOtherServicesUseCase(dependencies: self)
    }
    
    func resolve() -> GetMyProductSubMenuUseCase {
        return ESPrivateMenuMyProductsUseCase(dependencies: self)
    }
    
    func resolve() -> GetSofiaInvestmentSubMenuUseCase {
        return ESPrivateMenuSofiaInvestmentUseCase(dependencies: self)
    }
    
    func resolve() -> GetWorld123SubMenuUseCase {
        return ESPrivateMenuWorld123UseCase(dependencies: self)
    }
    
    func resolve() -> GetInsuranceDetailEnabledUseCase {
        return ESGetInsuranceDetailEnabledUseCase(dependencies: self)
    }
    
    func resolve() -> DisplayManagerPrivateMenuUseCase {
        return ESDisplayManagerPrivateMenuUseCase(dependencies: self)
    }
}

extension BaseMenuViewController: PrivateMenuToggleOutsider { }
