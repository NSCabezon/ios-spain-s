//
//  TripModuleCoordinator.swift
//  PersonalArea
//
//  Created by alvola on 16/03/2020.
//

import UI
import CoreFoundationLib
import SANLegacyLibrary
import CoreDomain

public protocol TripListCoordinatorDelegate: AnyObject {
    func didSelectMenu()
    func didSelectSearch()
    func didSelectOffer(_ offer: OfferRepresentable?)
    func didSelectAtm()
}

protocol TripListCoordinatorProtocol {
    func didSelectTrip(_ entity: TripEntity, country: CountryEntity)
    func gotoAddNewTrips(countries: [CountryEntity], trips: [TripEntity], replacing: Bool)
    func showDialog(tripEntity: TripEntity, accept: @escaping () -> Void)
    func showDialogError(action: @escaping () -> Void )
    func didSelectDismiss()
    func attach()
}

final class TripListCoordinator: NSObject, ModuleCoordinator {
    public weak var navigationController: UINavigationController?
    private let dependenciesEngine: DependenciesDefault
    lazy var personalAreaCoordinator: PersonalAreaMainModuleCoordinatorDelegate = {
        return self.dependenciesEngine.resolve(for: PersonalAreaMainModuleCoordinatorDelegate.self)
    }()
    lazy var tripDetailCoordinator: TripDetailCoordinator = {
        return TripDetailCoordinator(
            dependenciesResolver: dependenciesEngine,
            navigationController: navigationController
        )
    }()
    
    public init(dependenciesResolver: DependenciesResolver, navigationController: UINavigationController?) {
        self.navigationController = navigationController
        self.dependenciesEngine = DependenciesDefault(father: dependenciesResolver)
        super.init()
        self.setupDependencies()
    }
    
    public func start() {
        let viewController = self.dependenciesEngine.resolve(for: TripListViewProtocol.self)
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func attach() {
        guard self.navigationController?.viewControllers.count ?? 0 > 3 else { return }
        self.navigationController?.viewControllers.remove(at: 2)
    }
}

extension TripListCoordinator: TripListCoordinatorProtocol {
    func didSelectDismiss() {
        guard let securityArea = self.navigationController?.viewControllers[1] else { return }
        self.navigationController?.popToViewController(securityArea, animated: true)
    }
    
    func didSelectTrip(_ entity: TripEntity, country: CountryEntity) {
        self.dependenciesEngine.register(for: TripDetailConfiguration.self) { _ in
            return TripDetailConfiguration(selectedTrip: entity, selectedCountry: country)
        }
        self.tripDetailCoordinator.start()
    }
    
    func gotoAddNewTrips(countries: [CountryEntity], trips: [TripEntity], replacing: Bool) {
        self.dependenciesEngine.register(for: NoTripConfiguration.self) { _ in
            return NoTripConfiguration(countries: countries, trips: trips)
        }
        if replacing {
            handleViewControllersReplacing()
        }
        let noTripCoordinator = NoTripCoordinator(
            dependenciesResolver: self.dependenciesEngine,
            navigationController: self.navigationController
        )
        noTripCoordinator.start()
    }
    
    func showDialog(tripEntity: TripEntity, accept: @escaping () -> Void) {
        self.personalAreaCoordinator.showAlertDialog(
            acceptTitle: localized("generic_button_accept"),
            cancelTitle: localized("generic_button_cancel"),
            title: localized("yourTrips_alert_deleteTrip",
                             [StringPlaceholder(.value, tripEntity.country.name)]),
            body: localized("yourTrips_alert_sure"),
            acceptAction: accept,
            cancelAction: nil
        )
    }
    
    func showDialogError(action: @escaping () -> Void ) {
        self.personalAreaCoordinator.showAlertDialog(
            acceptTitle: localized("generic_button_accept"),
            cancelTitle: nil,
            title: localized("generic_title_alertError"),
            body: localized("yourTrips_alert_errorCountry"),
            acceptAction: action,
            cancelAction: nil
        )
    }
}

// MARK: - Private Methods
private extension TripListCoordinator {
    
    var securityAreaViewController: SecurityAreaViewController? {
         return navigationController?.viewControllers[1] as? SecurityAreaViewController
    }
    
    func setupDependencies() {
        self.dependenciesEngine.register(for: TripListCoordinatorProtocol.self) { _ in
            return self
        }
        
        self.dependenciesEngine.register(for: TripsDataSourceProtocol.self) {
            return TripsDataSource(dependenciesEngine: $0)
        }
        
        self.dependenciesEngine.register(for: TripListPresenterProtocol.self) { dependenciesResolver in
            let presenter = TripListPresenter(dependenciesResolver: dependenciesResolver)
            return presenter
        }
        
        self.dependenciesEngine.register(for: TripListViewProtocol.self) { dependenciesResolver in
            let presenter = dependenciesResolver.resolve(for: TripListPresenterProtocol.self)
            let view = TripListViewController(nibName: "TripListViewController", bundle: .module, presenter: presenter)
            presenter.view = view
            return view
        }
    }
    
    func handleViewControllersReplacing() {
        securityAreaViewController?.isReplacingViewControllersStack = true
        self.navigationController?.viewControllers.removeLast(1)
    }
}
