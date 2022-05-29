import Foundation
import OpenCombine
import CoreDomain
import CoreFoundationLib
import OpenCombineDispatch

enum PublicMenuState: State {
    case idle
    case loading
    case optionsLoaded([[PublicMenuElementRepresentable]])
}

final class PublicMenuViewModel {
    
    private let dependencies: PublicMenuDependenciesResolver
    private var anySubscriptions: Set<AnyCancellable> = []
    private let stateSubject = CurrentValueSubject<PublicMenuState, Never>(.idle)
    var state: AnyPublisher<PublicMenuState, Never>
    
    init(dependencies: PublicMenuDependenciesResolver) {
        self.dependencies = dependencies
        state = stateSubject.eraseToAnyPublisher()
    }
    
    func viewDidLoad() {
        loadReloadPublished()
        loadConfiguration()
    }
    
    func loadConfiguration() {
        subscribePublicMenuConfiguration()
    }
    
    func didSelectAction(_ action: PublicMenuAction) {
        switch action {
        case let .openURL(url):
            coordinator.openUrl(url)
        case .goToATMLocator:
            coordinator.goToAtmLocator()
        case .goToStockholders:
            coordinator.goToStockholders()
        case .goToOurProducts:
            coordinator.goToOurProducts() 
        case .goToHomeTips:
            coordinator.goToHomeTips()
        case .callPhone(number: let number):
            let url = "tel://\(number.notWhitespaces())"
            coordinator.openUrl(url)
        case .none, .toggleSideMenu:
            break
        case .custom(action: let action):
            coordinator
                .set(action)
                .goToCustomAction()
        case .comingSoon:
            coordinator.comingSoon()
        }
        guard action != .comingSoon else { return }
        coordinator.toggleSideMenu()
    }
    
    func didSelectOffer(offer: OfferRepresentable) {
        coordinator.toggleSideMenu()
        coordinator.goToPublicOffer(offer: offer)
        trackEvent(.offer, parameters: [.offerId: offer.identifier])
    }
    
    func trackEvent(_ event: String) {
        if let action = PublicMenuPage.Action(rawValue: event) {
            self.trackEvent(action, parameters: [:])
        }
    }
}

private extension PublicMenuViewModel {
    var coordinator: PublicMenuCoordinator {
        dependencies.resolve()
    }
    
    func subscribePublicMenuConfiguration() {
        configurationAndOfferPublisher()
            .subscribe(on: Schedulers.global)
            .receive(on: Schedulers.main)
            .sink { [unowned self] (menuConfiguration, offers) in
                self.stateSubject.send(.optionsLoaded(menuConfiguration + offers))
            }
            .store(in: &anySubscriptions)
    }
    
    func menuConfigurationPublisher() -> AnyPublisher<[[PublicMenuElementRepresentable]], Never> {
        return publicMenuConfigurationPublisher()
            .flatMap { [unowned self] menuConfiguration in
                self.userCommercialSegmentPublisher(menuConfiguration)
            }
            .flatMap { [unowned self] commertialSegmentConfigFiltered in
                self.homeTipsPublisher(commertialSegmentConfigFiltered)
            }
            .eraseToAnyPublisher()
    }
    
    func loadReloadPublished() {
        actionsRepository.reloadPublicMenu()
            .filter { needLoad in
                return needLoad == true
            }.sink { [unowned self] _ in
                self.loadConfiguration()
            }.store(in: &anySubscriptions)
    }
}

private extension PublicMenuViewModel {
    var getPublicMenuConfigurationUseCase: GetPublicMenuConfigurationUseCase {
        dependencies.resolve()
    }
    
    var getUserCommercialSegmentUseCase: GetUserCommercialSegmentUseCase {
        dependencies.resolve()
    }
    
    var getHomeTipsCountUseCase: GetHomeTipsCountUseCase {
        dependencies.resolve()
    }
    
    var publicMenuOffersUseCase: GetPublicMenuOffersUseCase {
        dependencies.resolve()
    }
    
    var actionsRepository: PublicMenuActionsRepository {
        dependencies.external.resolve()
    }
}

private extension PublicMenuViewModel {
    func configurationAndOfferPublisher() -> AnyPublisher<([[PublicMenuElementRepresentable]], [[PublicMenuElementRepresentable]]), Never> {
        return Publishers.CombineLatest(
            menuConfigurationPublisher(),
            publicMenuOffersPublisher()
        ).eraseToAnyPublisher()
    }
    
    func publicMenuConfigurationPublisher() -> AnyPublisher<[[PublicMenuElementRepresentable]], Never> {
        return getPublicMenuConfigurationUseCase.fetchMenuConfiguration()
    }
    
    func userCommercialSegmentPublisher(_ elements: [[PublicMenuElementRepresentable]]) -> AnyPublisher<[[PublicMenuElementRepresentable]], Never> {
        return getUserCommercialSegmentUseCase.filterUserCommercialSegmentElem(elements)
    }
    
    func homeTipsPublisher(_ elements: [[PublicMenuElementRepresentable]]) -> AnyPublisher<[[PublicMenuElementRepresentable]], Never> {
        return getHomeTipsCountUseCase.filterHomeTipsElem(elements)
    }
    
    func publicMenuOffersPublisher() -> AnyPublisher<[[PublicMenuElementRepresentable]], Never> {
        return publicMenuOffersUseCase.publicMenuValidOffers()
    }
    
    func reloadMenu() -> AnyPublisher<Bool, Never> {
        return actionsRepository.reloadPublicMenu()
    }
}

extension PublicMenuViewModel: AutomaticScreenActionTrackable {
    var trackerManager: TrackerManager {
        return dependencies.external.resolve()
    }
    
    var trackerPage: PublicMenuPage {
        return PublicMenuPage()
    }
}
