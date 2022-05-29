//
//  PersonalAreaAppPermissionsExternalDependenciesResolver.swift
//  PersonalArea
//
//  Created by alvola on 9/5/22.
//

import Foundation
import CoreFoundationLib
import UI

public protocol PersonalAreaAppPermissionsExternalDependenciesResolver: ShareDependenciesResolver {
    func resolve() -> DependenciesResolver
    func personalAreaAppPermissionsCoordinator() -> Coordinator
}

extension PersonalAreaAppPermissionsExternalDependenciesResolver {
    public func personalAreaAppPermissionsCoordinator() -> Coordinator {
        return DefaultAppPermissionsModuleCoordinator(dependenciesResolver: self,
                                                      navigationController: resolve())
    }
}
