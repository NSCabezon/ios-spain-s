//  
//  AnalysisAreaCategoryDetailCoordinator.swift
//  Menu
//
//  Created by Jose Javier Montes Romero on 29/3/22.
//

import Foundation
import CoreFoundationLib
import UI

protocol AnalysisAreaCategoryDetailCoordinator: BindableCoordinator {
    func openPrivateMenu()
    func openFilters(filterOutsider: AnalysisAreaFilterOutsider, filtersApplied: AnalysisAreaFilterRepresentable?)
    func openViewPDF()
    func openSearchView()
    func showSCA(delegate: OtpScaAccountPresenterDelegate)
    func showHome()
}

final class DefaultAnalysisAreaCategoryDetailCoordinator: AnalysisAreaCategoryDetailCoordinator {
    
    weak var navigationController: UINavigationController?
    var onFinish: (() -> Void)?
    var childCoordinators: [Coordinator] = []
    private let externalDependencies: AnalysisAreaCategoryDetailExternalDependenciesResolver
    lazy var dataBinding: DataBinding = dependencies.resolve()
    
    private lazy var dependencies: Dependency = {
        Dependency(dependencies: externalDependencies, coordinator: self)
    }()
    
    public init(dependencies: AnalysisAreaCategoryDetailExternalDependenciesResolver, navigationController: UINavigationController?) {
        self.navigationController = navigationController
        self.externalDependencies = dependencies
    }
}

extension DefaultAnalysisAreaCategoryDetailCoordinator {
    func start() {
        navigationController?.pushViewController(dependencies.resolve(), animated: true)
    }
    
    func openPrivateMenu() {
        let coordinator = dependencies.external.privateMenuCoordinator()
        coordinator.start()
        append(child: coordinator)
    }
    
    func openViewPDF() {
        ToastCoordinator("Coming soon...").start()
    }
    
    func openFilters(filterOutsider: AnalysisAreaFilterOutsider, filtersApplied: AnalysisAreaFilterRepresentable?) {
        let coordinator = dependencies.external.movementsFilterCoordinator()
        coordinator
            .set(filterOutsider)
            .set(filtersApplied)
            .start()
        append(child: coordinator)
    }
    
    func openSearchView() {
        ToastCoordinator("Coming soon...").start()
    }
    
    func showSCA(delegate: OtpScaAccountPresenterDelegate) {
//        let coordinator = dependencies.external.otpCoordinator()
//        coordinator
//            .set(delegate)
//            .start()
//        append(child: coordinator)
    }
    
    func showHome() {
        navigationController?.popViewController(animated: !UIAccessibility.isVoiceOverRunning)
    }
}

private extension DefaultAnalysisAreaCategoryDetailCoordinator {
    struct Dependency: AnalysisAreaCategoryDetailDependenciesResolver {
        let dependencies: AnalysisAreaCategoryDetailExternalDependenciesResolver
        let coordinator: AnalysisAreaCategoryDetailCoordinator
        let dataBinding = DataBindingObject()
        
        var external: AnalysisAreaCategoryDetailExternalDependenciesResolver {
            return dependencies
        }
        
        func resolve() -> AnalysisAreaCategoryDetailCoordinator {
            return coordinator
        }
        
        func resolve() -> DataBinding {
            return dataBinding
        }
    }
}
