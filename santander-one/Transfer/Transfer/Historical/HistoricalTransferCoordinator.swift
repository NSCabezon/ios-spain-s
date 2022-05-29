//
//  HistoricalCoordinator.swift
//  Transfer
//
//  Created by Cristobal Ramos Laina on 01/04/2020.
//

import Foundation
import CoreFoundationLib
import UI

protocol HistoricalTransferCoordinatorProtocol {
    func dismiss()
    func gotoTransferDetailWithConfiguration(_ configuration: TransferDetailConfiguration)
}

public final class HistoricalTransferCoordinator: ModuleCoordinator {
    
    public weak var navigationController: UINavigationController?
    private let dependenciesEngine: DependenciesDefault
        
    private var transferDelegate: TransferHomeModuleCoordinatorDelegate {
        self.dependenciesEngine.resolve(for: TransferHomeModuleCoordinatorDelegate.self)
    }
    
    public init(dependenciesResolver: DependenciesResolver, navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.dependenciesEngine = DependenciesDefault(father: dependenciesResolver)
        self.setupDependencies()
    }
    
    public func start() {
        let controller = self.dependenciesEngine.resolve(for: HistoricalTransferViewProtocol.self)
        self.navigationController?.blockingPushViewController(controller, animated: true)
    }
    
    private func setupDependencies() {
        
        self.dependenciesEngine.register(for: HistoricalTransferCoordinatorProtocol.self) {_ in
            return self
        }
        
        self.dependenciesEngine.register(for: HistoricalTransferPresenterProtocol.self) { dependenciesResolver in
            return HistoricalTransferPresenter(dependenciesResolver: dependenciesResolver)
        }
        
        self.dependenciesEngine.register(for: HistoricalTransferViewProtocol.self) { _ in
            let presenter = self.dependenciesEngine.resolve(for: HistoricalTransferPresenterProtocol.self)
            let viewController = HistoricalTransferViewController(presenter: presenter)
            presenter.view = viewController
            return viewController
        }
        
        self.dependenciesEngine.register(for: GetTransfersHomeUseCase.self) { _ in
            return GetTransfersHomeUseCase(dependenciesResolver: self.dependenciesEngine)
        }
        
        self.dependenciesEngine.register(for: GetGlobalPositionV2UseCase.self) { dependenciesResolver in
            return GetGlobalPositionV2UseCase(dependenciesResolver: dependenciesResolver)
        }
    }
}
extension HistoricalTransferCoordinator: HistoricalTransferCoordinatorProtocol {
    func dismiss() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func gotoTransferDetailWithConfiguration(_ configuration: TransferDetailConfiguration) {
        let emittedTransferDetailCoordinator = TransferDetailCoordinator(dependenciesResolver: self.dependenciesEngine, navigationController: self.navigationController)
        emittedTransferDetailCoordinator.goToDetail(with: configuration)
    }
}
