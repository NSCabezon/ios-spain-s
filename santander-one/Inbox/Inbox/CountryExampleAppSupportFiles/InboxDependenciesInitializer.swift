//
//  InboxDependenciesInitializer.swift
//  Inbox
//
//  Created by Carlos Monfort Gómez on 8/9/21.
//

import Foundation
import QuickSetup
import CoreFoundationLib
import Localization

public final class InboxDependenciesInitializer: ModuleDependenciesInitializer {
    private let dependencies: DependenciesInjector
    
    public init(dependencies: DependenciesInjector & DependenciesResolver) {
        self.dependencies = dependencies
    }
    
    public func registerDependencies() {
        self.dependencies.register(for: InboxHomeModuleCoordinatorDelegate.self) { _ in
            return InboxHomeModuleCoordinatorImp()
        }
        
        self.dependencies.register(for: InboxNotificationCoordinatorDelegate.self) { _ in
            return InboxNotificationCoordinatorImp()
        }
    }
}
