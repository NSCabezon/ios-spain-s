//
//  PersonalAreaSecurityDependenciesResolver.swift
//  PersonalArea
//
//  Created by alvola on 11/4/22.
//

import Foundation
import CoreFoundationLib

protocol PersonalAreaSecurityDependenciesResolver {
    var external: PersonalAreaSecurityExternalDependenciesResolver { get }
    func resolve() -> DataBinding
}
