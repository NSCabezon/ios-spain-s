//
//  PersonalAreaBasicInfoDependenciesResolver.swift
//  PersonalArea
//
//  Created by alvola on 7/4/22.
//

import Foundation
import CoreFoundationLib

protocol PersonalAreaBasicInfoDependenciesResolver {
    var external: PersonalAreaBasicInfoExternalDependenciesResolver { get }
}
