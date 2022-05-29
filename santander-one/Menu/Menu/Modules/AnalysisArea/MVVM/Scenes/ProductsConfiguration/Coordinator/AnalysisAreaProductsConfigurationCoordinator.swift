//  
//  AnalysisAreaProductsConfigurationCoordinator.swift
//  Menu
//
//  Created by Luis Escámez Sánchez on 15/3/22.
//

import Foundation
import CoreFoundationLib
import UI
import CoreDomain

protocol AnalysisAreaProductsConfigurationCoordinator: BindableCoordinator {
    func didTapContinue()
    func openDeleteOtherBank(bank: ProducListConfigurationOtherBanksRepresentable, updateCompaniesAfterDeleteBankOutsider: UpdateCompaniesOutsider)
    func executeOffer(_ offer: OfferRepresentable)
    func back()
    func goToPG()
}

final class DefaultAnalysisAreaProductsConfigurationCoordinator: AnalysisAreaProductsConfigurationCoordinator {    
    weak var navigationController: UINavigationController?
    var onFinish: (() -> Void)?
    var childCoordinators: [Coordinator] = []
    private let externalDependencies: AnalysisAreaProductsConfigurationExternalDependenciesResolver
    lazy var dataBinding: DataBinding = dependencies.resolve()
    
    private lazy var dependencies: Dependency = {
        Dependency(dependencies: externalDependencies, coordinator: self)
    }()
    
    public init(dependencies: AnalysisAreaProductsConfigurationExternalDependenciesResolver, navigationController: UINavigationController?) {
        self.navigationController = navigationController
        self.externalDependencies = dependencies
    }
}

extension DefaultAnalysisAreaProductsConfigurationCoordinator {
    func start() {
        navigationController?.pushViewController(dependencies.resolve(), animated: !UIAccessibility.isVoiceOverRunning)
    }
    
    func back() {
        guard let viewControllers = navigationController?.viewControllers,
              let viewController = viewControllers[safe: viewControllers.count - 2] as? AnalysisAreaViewController
        else { return }
        navigationController?.popViewController(animated: !UIAccessibility.isVoiceOverRunning)
    }
    
    func goToPG() {
        navigationController?.popToRootViewController(animated: true)
    }
    
    func openAddNewBankView() {
        ToastCoordinator("Open add new bank tapped").start()
    }
    
    func didTapContinue() {
        ToastCoordinator("Continue tapped").start()
    }
    
    func openDeleteOtherBank(bank: ProducListConfigurationOtherBanksRepresentable, updateCompaniesAfterDeleteBankOutsider: UpdateCompaniesOutsider) {
        let coordinator = dependencies.external.deleteOtherBankConnectionCoordinator()
        coordinator
            .set(bank)
            .set(updateCompaniesAfterDeleteBankOutsider)
            .start()
        append(child: coordinator)
    }
    
    func executeOffer(_ offer: OfferRepresentable) {
        let coordinator = dependencies.external.offersCoordinator()
        coordinator.dataBinding.set(offer)
        coordinator.start()
    }
}

private extension DefaultAnalysisAreaProductsConfigurationCoordinator {
    struct Dependency: AnalysisAreaProductsConfigurationDependenciesResolver {
        let dependencies: AnalysisAreaProductsConfigurationExternalDependenciesResolver
        let coordinator: AnalysisAreaProductsConfigurationCoordinator
        let dataBinding = DataBindingObject()
        
        var external: AnalysisAreaProductsConfigurationExternalDependenciesResolver {
            return dependencies
        }
        
        func resolve() -> AnalysisAreaProductsConfigurationCoordinator {
            return coordinator
        }
        
        func resolve() -> DataBinding {
            return dataBinding
        }
    }
}
