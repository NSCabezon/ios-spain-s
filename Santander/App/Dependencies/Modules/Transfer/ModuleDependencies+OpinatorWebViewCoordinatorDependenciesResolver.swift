//
//  ModuleDependencies+OpinatorWebViewCoordinatorDependenciesResolver.swift
//  Santander
//
//  Created by Cristobal Ramos Laina on 25/3/22.
//

import Foundation
import Operative

extension ModuleDependencies: OpinatorWebViewCoordinatorDependenciesResolver {
    func resolve() -> OperativeContainerCoordinatorDelegate {
        return oldResolver.resolve()
    }
}
