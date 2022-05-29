//
//  PersonalAreaExternalDependenciesResolver.swift
//  PersonalArea
//
//  Created by alvola on 6/4/22.
//

import Foundation

public protocol PersonalAreaExternalDependenciesResolver:
    PersonalAreaHomeExternalDependenciesResolver,
    PersonalAreaBasicInfoExternalDependenciesResolver,
    PersonalAreaConfigurationExternalDependenciesResolver,
    PersonalAreaSecurityExternalDependenciesResolver,
    PersonalAreaPGPersonalizationExternalDependenciesResolver,
    PersonalAreaDigitalProfileExternalDependenciesResolver,
    PersonalAreaAppPermissionsExternalDependenciesResolver {}
