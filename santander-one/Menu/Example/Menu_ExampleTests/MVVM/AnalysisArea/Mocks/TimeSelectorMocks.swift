//
//  TimeSelectorMocks.swift
//  Menu_ExampleTests
//
//  Created by Miguel Ferrer Fornali on 25/3/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UI
import Menu
import CoreDomain
import CoreFoundationLib
@testable import Menu

final class TimeSelectorCoordinatorMock: TimeSelectorCoordinator {
    lazy var dataBinding: DataBinding = dependencies.resolve()
    var childCoordinators: [Coordinator] = []
    var onFinish: (() -> Void)?
    var navigationController: UINavigationController?
    private var dependencies: TimeSelectorDependenciesResolver
    
    var didOpenMenu = false
    var didDismiss = false
    
    init(dependencies: TimeSelectorDependenciesResolver) {
        self.dependencies = dependencies
    }
    
    func openMenu() {
        didOpenMenu = true
    }
    
    func dismiss() {
        didDismiss = true
    }
    
    func start() {}
    
    func close() {}
}

struct TimeSelectorDependenciesResolverMock: TimeSelectorDependenciesResolver {
    var external: TimeSelectorExternalDependenciesResolver
    var coordinator: TimeSelectorCoordinator!
    
    func resolve() -> DataBinding {
        return DataBindingObject()
    }
    
    func resolve() -> TimeSelectorCoordinator {
        return coordinator
    }
    
}

final class TimeSelectorExternalDependenciesResolverMock: TimeSelectorExternalDependenciesResolver {
    private let oldDependencies: DependenciesInjector & DependenciesResolver
    
    init(oldDependencies: DependenciesInjector & DependenciesResolver) {
        self.oldDependencies = oldDependencies
    }
    
    func resolve() -> UINavigationController {
        return UINavigationController()
    }
    
    func privateMenuCoordinator() -> Coordinator {
        ToastCoordinator()
    }
    func resolve() -> DependenciesResolver {
        oldDependencies
    }
}
