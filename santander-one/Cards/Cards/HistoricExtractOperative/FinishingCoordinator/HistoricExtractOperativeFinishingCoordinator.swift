//
//  HistoricExtractOperativeFinishingCoordinator.swift
//  Cards
//
//  Created by Ignacio González Miró on 12/11/2020.
//

import Operative
import CoreFoundationLib
import UI

protocol HistoricExtractOperativeFinishingCoordinatorProtocol: OperativeFinishingCoordinator {
    func goToHistoricExtract()
    func goToMapView(_ selectedCard: CardEntity, type: CardMapTypeConfiguration)
}

class HistoricExtractOperativeFinishingCoordinator: HistoricExtractOperativeFinishingCoordinatorProtocol {
    private let dependenciesEngine: DependenciesResolver & DependenciesInjector
    private let externalDependencies: CardExternalDependenciesResolver
    private weak var navigationController: UINavigationController?
    
    init(dependenciesResolver: DependenciesResolver,
         navigationController: UINavigationController?,
         externalDependencies: CardExternalDependenciesResolver) {
        self.externalDependencies = externalDependencies
        self.dependenciesEngine = DependenciesDefault(father: dependenciesResolver)
        self.navigationController = navigationController
    }

    func goToHistoricExtract() {
        let controller = self.dependenciesEngine.resolve(for: HistoricExtractViewController.self)
        self.navigationController?.blockingPushViewController(controller, animated: true)
    }
    
    func goToMapView(_ selectedCard: CardEntity, type: CardMapTypeConfiguration) {
        let coordinator = externalDependencies.shoppingMapCoordinator()
        let configuration = CardMapConfiguration(type: type,
                                                 card: selectedCard.representable)
        coordinator.set(configuration)
        coordinator.start()
    }
}

extension HistoricExtractOperativeFinishingCoordinatorProtocol {
    func didFinishSuccessfully(_ coordinator: OperativeContainerCoordinatorProtocol, operative: Operative) {
        guard let finishingOption: HistoricExtractOperative.FinishingOption = operative.container?.getOptional() else {
            if let sourceView = coordinator.sourceView {
                coordinator.navigationController?.popToViewController(sourceView, animated: true)
            } else {
                coordinator.navigationController?.popToRootViewController(animated: true)
            }
            return
        }
        switch finishingOption {
        case .historicExtract:
            self.goToHistoricExtract()
        }
    }
}
