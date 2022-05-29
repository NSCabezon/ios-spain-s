//
//  NoTripCoordinator.swift
//  PersonalManager
//
//  Created by Juan Carlos López Robles on 3/24/20.
//

import Foundation
import CoreFoundationLib
import UI

public protocol NoTripCoordinatorDelegate {
    func didSelectMenu()
    func didSelectSearch()
    func showLoading(completion: (() -> Void)?)
    func hideLoading(completion: (() -> Void)?)
}

protocol NoTripCoordinatorProtocol {
    func gotoTripList()
    func goBackToTripList()
    func didSelectDismiss()
    func attach()
}

final class NoTripCoordinator: NSObject, ModuleCoordinator {
    weak var navigationController: UINavigationController?
    let dependenciesEngine: DependenciesDefault
    
    private var securityAreaViewController: SecurityAreaViewController? {
        navigationController?.viewControllers[1] as? SecurityAreaViewController
    }
    
    init(dependenciesResolver: DependenciesResolver, navigationController: UINavigationController?) {
        self.dependenciesEngine = DependenciesDefault(father: dependenciesResolver)
        self.navigationController = navigationController
        super.init()
        self.setupDependencies()
    }
    
    func start() {
        let viewController = self.dependenciesEngine.resolve(for: NoTripViewProtocol.self)
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func attach() {
        let configurartion = self.dependenciesEngine.resolve(for: NoTripConfiguration.self)
        guard configurartion.trips.isEmpty else { return }
        guard self.navigationController?.viewControllers.count ?? 0 > 3 else { return }
        self.navigationController?.viewControllers.remove(at: 2)
    }
    
    private func setupDependencies() {
        self.dependenciesEngine.register(for: NoTripCoordinatorProtocol.self) { _ in
            return self
        }
        
        self.dependenciesEngine.register(for: TripsDataSourceProtocol.self) {
            return TripsDataSource(dependenciesEngine: $0)
        }
        
        self.dependenciesEngine.register(for: NoTripPresenterProtocol.self) { dependenciesResolver in
            let presenter = NoTripPresenter(dependenciesResolver: dependenciesResolver)
            return presenter
        }
        
        self.dependenciesEngine.register(for: NoTripViewProtocol.self) { dependenciesResolver in
            let presenter = dependenciesResolver.resolve(for: NoTripPresenterProtocol.self)
            let view = NoTripViewController(nibName: "NoTripViewController", bundle: Bundle.module, presenter: presenter)
            presenter.view = view
            return view
        }
    }
}

extension NoTripCoordinator: NoTripCoordinatorProtocol {
    func gotoTripList() {
        self.removePreviousTripList()
        let tripListCoordinator = TripListCoordinator(
            dependenciesResolver: self.dependenciesEngine,
            navigationController: self.navigationController
        )
        securityAreaViewController?.isReplacingViewControllersStack = false
        tripListCoordinator.start()
    }
    
    private func removePreviousTripList() {
        let viewControllers = self.navigationController?.viewControllers ?? []
        guard viewControllers.count > 2 else { return }
        self.navigationController?.setViewControllers(Array(viewControllers.prefix(2)), animated: false)
    }
    
    func goBackToTripList() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func didSelectDismiss() {
        guard let securityArea = securityAreaViewController else { return }
        securityArea.isReplacingViewControllersStack = false
        self.navigationController?.popToViewController(securityArea, animated: true)
    }
}
