//
//  MovementDetailPresenter.swift
//  Menu
//
//  Created by Boris Chirino Fernandez on 24/06/2020.
//

import Foundation
import CoreFoundationLib

protocol MovementDetailPresenterProtocol: AnyObject, MenuTextWrapperProtocol {
    var view: MovementDetailViewControllerViewProtocol? { get set }
    func didSelectMenu()
    func didSelectDismiss()
    func viewDidLoad()
}

final class MovementDetailPresenter {
    weak var view: MovementDetailViewControllerViewProtocol?
    private var viewModel: MovementDetailViewModel?
    
    let dependenciesResolver: DependenciesResolver
    private var coordinator: MovementDetailCoordinatorCoordinatorProtocol {
        self.dependenciesResolver.resolve(for: MovementDetailCoordinatorCoordinatorProtocol.self)
    }
    private var coordinatorDelegate: OldAnalysisAreaCoordinatorDelegate {
        self.dependenciesResolver.resolve(for: OldAnalysisAreaCoordinatorDelegate.self)
    }
    private var configuration: MovementDetailConfiguration {
        return self.dependenciesResolver.resolve(for: MovementDetailConfiguration.self)
    }
    
    private lazy var useCaseHandler: UseCaseHandler = {
        dependenciesResolver.resolve(for: UseCaseHandler.self)
    }()
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
}

extension MovementDetailPresenter: MovementDetailPresenterProtocol {
    func didSelectMenu() {
        self.coordinatorDelegate.didSelectMenu()
    }
    
    func didSelectDismiss() {
        coordinator.dismiss()
    }
    
    func viewDidLoad() {
        self.viewModel = configuration.detailMovements
        guard let viewModel = configuration.detailMovements else {
            return
        }
        self.view?.updateViewModel(viewModel, selectedIndex: configuration.selectedIndex)
    }
}
