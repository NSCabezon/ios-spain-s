import CoreFoundationLib

protocol SecureDeviceTutorialPresenterProtocol {
    var view: SecureDeviceTutorialViewProtocol? { get set }
    var moduleCoordinator: SecureDeviceTutorialCoordinator? { get set }
    func goToUpdate()
    func viewDidLoad()
    func backDidPressed()
    func closeDidPressed()
    func videoDidPressed()
}

class SecureDeviceTutorialPresenter {
    weak var view: SecureDeviceTutorialViewProtocol?
    weak var moduleCoordinator: SecureDeviceTutorialCoordinator?
    private var device: OTPPushDeviceEntity?
    private let dependenciesResolver: DependenciesResolver
    private var personalAreaCoordinator: PersonalAreaMainModuleCoordinatorDelegate? {
        return dependenciesResolver.resolve(for: PersonalAreaMainModuleCoordinatorDelegate.self)
    }
    private var getPullOffersUseCase: GetPullOffersUseCase {
        self.dependenciesResolver.resolve()
    }
    private let locations: [PullOfferLocation] = PullOffersLocationsFactoryEntity().secureDeviceTutorial
    private let videoLocationKey = PersonalAreaPullOffers.secureDeviceTutorial
    private var pullOfferCandidates: [PullOfferLocation: OfferEntity]?
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
}

// MARK: - Private methods

private extension SecureDeviceTutorialPresenter {
    func loadOffers() {
        UseCaseWrapper(
            with: getPullOffersUseCase.setRequestValues(requestValues: GetPullOffersUseCaseInput(locations: self.locations)),
            useCaseHandler: self.dependenciesResolver.resolve(for: UseCaseHandler.self),
            onSuccess: { [weak self] result in
                self?.pullOfferCandidates = result.pullOfferCandidates
                self?.showLocation()
            }
        )
    }
    
    func showLocation() {
        if self.pullOfferCandidates?.contains(location: self.videoLocationKey) == true {
            self.view?.showVideo()
        }
    }
}

// MARK: - Private SecureDeviceTutorialPresenterProtocol

extension SecureDeviceTutorialPresenter: SecureDeviceTutorialPresenterProtocol {
    func viewDidLoad() {
        self.trackEvent(.register, parameters: [:])
        self.loadOffers()
    }
    
    func goToUpdate() {
        self.personalAreaCoordinator?.showSecureDeviceOperative(device: self.device)
    }
    
    func backDidPressed() {
        personalAreaCoordinator?.didSelectDismiss()
    }
    
    func closeDidPressed() {
        personalAreaCoordinator?.didSelectDismiss()
    }
    
    func videoDidPressed() {
        let videoLocation = self.locations.first { $0.stringTag == self.videoLocationKey }
        guard let location = videoLocation else {
            return
        }
        guard let offer = self.pullOfferCandidates?[location] else {
            return
        }
        self.personalAreaCoordinator?.didSelectOffer(offer: offer)
    }
}

extension SecureDeviceTutorialPresenter: AutomaticScreenActionTrackable {
    var trackerManager: TrackerManager {
        return dependenciesResolver.resolve(for: TrackerManager.self)
    }
    
    var trackerPage: SecurityAreaOtpPushPage {
        return SecurityAreaOtpPushPage()
    }
}
