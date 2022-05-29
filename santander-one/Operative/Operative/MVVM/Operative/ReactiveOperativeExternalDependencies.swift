//
//  ReactiveOperativeExternalDependencies.swift
//  Operative
//
//  Created by José Carlos Estela Anguita on 25/1/22.
//

import Foundation
import CoreFoundationLib

public protocol ReactiveOperativeExternalDependencies {
    func resolve() -> SessionDataManager
    func resolve() -> DependenciesResolver
}
