//
//  PersonalAreaAppPermissionsDependenciesResolver.swift
//  PersonalArea
//
//  Created by alvola on 9/5/22.
//

import Foundation
import CoreFoundationLib

protocol PersonalAreaAppPermissionsDependenciesResolver {
    var external: PersonalAreaAppPermissionsExternalDependenciesResolver { get }
}
