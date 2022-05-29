import Foundation
import CoreFoundationLib

protocol CardBoardingGeolocationPresenterProtocol: AnyObject {
    var view: CardBoardingGeolocationViewProtocol? { get set }
    func viewDidLoad()
    func didViewBecomeActive()
    func didSelectBack()
    func didSelectNext()
    func didGeolocationPermissionChange()
    func viewDidLayoutSubviews()
}

class CardBoardingGeolocationPresenter {
    
    weak var view: CardBoardingGeolocationViewProtocol?
    let dependenciesResolver: DependenciesResolver
    private var mustShowActivationSuccess = false
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    private var coordinator: CardBoardingCoordinatorProtocol {
        return dependenciesResolver.resolve(for: CardBoardingCoordinatorProtocol.self)
    }
    
    private var locationPermission: LocationPermission {
        return self.dependenciesResolver.resolve(for: LocationPermission.self)
    }
}

extension CardBoardingGeolocationPresenter: CardBoardingGeolocationPresenterProtocol {
    func viewDidLoad() {
        self.setInitialUserLocationPermissionState()
        self.trackScreen()
    }
    
    func didViewBecomeActive() {
        self.setUserLocationPermissionState()
    }
    
    func viewDidLayoutSubviews() {
        guard self.mustShowActivationSuccess else { return }
        self.mustShowActivationSuccess = false
        self.view?.showActivationSuccessView()
    }

    func didGeolocationPermissionChange() {
        self.locationPermission.setLocationPermissions { [weak self] in
            self?.setUserLocationPermissionState()
        }
    }
    
    func didSelectBack() {
        self.coordinator.didSelectGoBackwards()
    }
    
    func didSelectNext() {
        self.coordinator.didSelectGoFoward()
    }
}

extension CardBoardingGeolocationPresenter: AutomaticScreenActionTrackable {
    var trackerPage: CardBoardignGeolocationPage {
        return CardBoardignGeolocationPage()
    }
    var trackerManager: TrackerManager {
        return dependenciesResolver.resolve(for: TrackerManager.self)
    }
}

private extension CardBoardingGeolocationPresenter {
    func setUserLocationPermissionState() {
        let isLocationEnabled = self.locationPermission.isLocationAccessEnabled()
        self.view?.setGeolocationStateView(isLocationEnabled)
        self.mustShowActivationSuccess = isLocationEnabled
        self.trackEvent(isLocationEnabled ? .activateLocation : .deactivateLocation, parameters: [:])
    }
    
    func setInitialUserLocationPermissionState() {
        let isLocationEnabled = self.locationPermission.isLocationAccessEnabled()
        self.view?.setGeolocationStateView(isLocationEnabled)
    }
}
