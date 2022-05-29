//
//  PersonalAreaConfigurationDependenciesResolver.swift
//  PersonalArea
//
//  Created by alvola on 11/4/22.
//

import Foundation

protocol PersonalAreaConfigurationDependenciesResolver {
    var external: PersonalAreaConfigurationExternalDependenciesResolver { get }
}
