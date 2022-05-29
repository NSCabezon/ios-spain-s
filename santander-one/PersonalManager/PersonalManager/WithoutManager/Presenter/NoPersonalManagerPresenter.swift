//
//  NoPersonalManagerPresenter.swift
//  PersonalManager
//
//  Created by alvola on 03/02/2020.
//

import CoreFoundationLib

protocol NoPersonalManagerPresenterProtocol: MenuTextWrapperProtocol {
    var view: NoPersonalManagerViewProtocol? { get set }
    func viewDidLoad()
    func searchAction()
    func drawerAction()
    func backButtonAction()
    func requestManagerAction()
}

final class NoPersonalManagerPresenter {
    
    weak var view: NoPersonalManagerViewProtocol?
    
    let dependenciesResolver: DependenciesResolver
    
    private var personalManagerCoordinator: PersonalManagerMainModuleCoordinatorDelegate? {
        return dependenciesResolver.resolve(for: PersonalManagerMainModuleCoordinatorDelegate.self)
    }
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
}

extension NoPersonalManagerPresenter: NoPersonalManagerPresenterProtocol {
    
    func viewDidLoad() {
        getIsSearchEnabled()
        self.trackScreen()
    }
    
    func searchAction() { personalManagerCoordinator?.didSelectSearch() }
    func drawerAction() { personalManagerCoordinator?.didSelectMenu() }
    func backButtonAction() { personalManagerCoordinator?.didSelectDismiss() }
    func requestManagerAction() {
        personalManagerCoordinator?.open(url: personalManagerCustomerSupportURL)
        self.trackEvent(.register, parameters: [:])
    }
}

extension NoPersonalManagerPresenter: AutomaticScreenActionTrackable {
    var trackerManager: TrackerManager {
        return dependenciesResolver.resolve(for: TrackerManager.self)
    }

    var trackerPage: NoPersonalManagerPage {
        return NoPersonalManagerPage()
    }
}

extension NoPersonalManagerPresenter: GlobalSearchEnabledManagerProtocol {
    private func getIsSearchEnabled() {
        getIsSearchEnabled(with: dependenciesResolver) { [weak self] response in
            self?.view?.isSearchEnabled = response
        }
    }
}
