//
//  BillsDependenciesInitializer.swift
//  Bills
//
//  Created by Daniel Gómez Barroso on 17/9/21.
//

import QuickSetup
import CoreFoundationLib
import Localization


public final class BillsDependenciesInitializer: ModuleDependenciesInitializer {
    private let dependencies: DependenciesInjector
    
    public init(dependencies: DependenciesInjector & DependenciesResolver) {
        self.dependencies = dependencies
    }
    
    public func registerDependencies() {
        self.dependencies.register(for: BillConfiguration.self) { _ in
            return BillConfiguration(account: nil)
        }
        self.dependencies.register(for: PaymentConfiguration.self) { _ in
            return PaymentConfiguration(true)
        }
        self.dependencies.register(for: BillHomeModuleCoordinatorDelegate.self) { _ in
            return BillHomeModuleCoordinatorMock()
        }
        self.dependencies.register(for: GlobalPositionWithUserPrefsRepresentable.self) { resolver in
            let globalPosition = resolver.resolve(for: GlobalPositionRepresentable.self)
            let merger = GlobalPositionPrefsMergerEntity(resolver: resolver, globalPosition: globalPosition, saveUserPreferences: false)
            return merger
        }
    }
}
