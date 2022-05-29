//
//  TripDetailCoordinator.swift
//  PersonalArea
//
//  Created by Carlos Monfort Gómez on 20/03/2020.
//

import Foundation
import CoreFoundationLib
import UI

public protocol TripDetailCoordinatorDelegate: AnyObject {
    func didSelectDismiss()
    func didSelectCallPhoneNumber(_ phoneNumber: String)
    func unlockSignatureKeyDidPress()
    func goToSmartLock()
    func goToAtms()
}

final class TripDetailCoordinator: NSObject, ModuleCoordinator {
    weak var navigationController: UINavigationController?
    private let dependenciesEngine: DependenciesDefault
    
    weak var tripModeCoordinatorDelegate: TripListCoordinatorDelegate?
    
    init(dependenciesResolver: DependenciesResolver, navigationController: UINavigationController?) {
        self.navigationController = navigationController
        self.dependenciesEngine = DependenciesDefault(father: dependenciesResolver)
        self.tripModeCoordinatorDelegate = dependenciesResolver.resolve(for: TripListCoordinatorDelegate.self)
        super.init()
        self.setupDependencies()
    }
    
    func start() {
        let controller = self.dependenciesEngine.resolve(for: TripDetailViewProtocol.self)
        self.navigationController?.blockingPushViewController(controller, animated: true)
    }
    
    // MARK: - Private
    private func setupDependencies() {
        self.dependenciesEngine.register(for: TripDetailCoordinatorDelegate.self) { _ in
            return self
        }
        
        self.dependenciesEngine.register(for: TripsDataSourceProtocol.self) {
            return TripsDataSource(dependenciesEngine: $0)
        }
        
        self.dependenciesEngine.register(for: TripDetailPresenterProtocol.self) { dependenciesResolver in
            return TripDetailPresenter(dependenciesResolver: dependenciesResolver)
        }
        
        self.dependenciesEngine.register(for: TripDetailViewProtocol.self) { dependenciesResolver in
            let presenter = dependenciesResolver.resolve(for: TripDetailPresenterProtocol.self)
            let view = TripDetailViewController(nibName: "TripDetailViewController",
                                                bundle: Bundle.module,
                                                presenter: presenter)
            presenter.view = view
            return view
        }
    }
}

extension TripDetailCoordinator: TripDetailCoordinatorDelegate {
    func didSelectDismiss() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func didSelectCallPhoneNumber(_ phoneNumber: String) {
        let numberToCall = phoneNumber.filterValidCharacters(characterSet: .decimalDigits)
        
        guard !numberToCall.isEmpty,
            let callUrl = URL(string: String(format: "tel://%@", numberToCall)) else { return }
        UIApplication.shared.open(callUrl)
    }
    
    func unlockSignatureKeyDidPress() {
        let mainModuleCoordinatorDelegate = self.dependenciesEngine.resolve(for: PersonalAreaMainModuleCoordinatorDelegate.self)
        mainModuleCoordinatorDelegate.didSelectMultichannelSignature()
    }
    
    func goToSmartLock() {
        let mainModuleCoordinatorDelegate = self.dependenciesEngine.resolve(for: PersonalAreaMainModuleCoordinatorDelegate.self)
        mainModuleCoordinatorDelegate.goToSmartLock()
    }
    
    func goToAtms() {
        self.tripModeCoordinatorDelegate?.didSelectAtm()
    }
}
