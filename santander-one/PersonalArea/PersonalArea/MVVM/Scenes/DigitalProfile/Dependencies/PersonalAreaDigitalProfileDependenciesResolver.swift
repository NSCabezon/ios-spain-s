//
//  PersonalAreaDigitalProfileDependenciesResolver.swift
//  PersonalArea
//
//  Created by alvola on 12/4/22.
//

import Foundation

protocol PersonalAreaDigitalProfileDependenciesResolver {
    var external: PersonalAreaDigitalProfileExternalDependenciesResolver { get }
}
