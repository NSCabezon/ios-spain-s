//
//  MenuModuleDependencies.swift
//  Santander
//
//  Created by alvola on 04/01/2022.
//

import Foundation
import Menu
import CoreFoundationLib
import RetailLegacy
import UI
import CoreDomain

extension ModuleDependencies: PublicMenuExternalDependenciesResolver {

    func resolve() -> PublicMenuToggleOutsider {
        self.drawer
    }

    func resolve() -> HomeTipsRepository {
        return SpainHomeTipsRepository(dependenciesResolver: oldResolver)
    }

    func resolve() -> PublicMenuRepository {
        return SpainPublicMenuRepository()
    }
}

extension BaseMenuViewController: PublicMenuToggleOutsider { }
