import CoreFoundationLib

protocol CardControlDistributionPresenterProtocol {
    var view: CardControlDistributionViewProtocol? { get set }
    func viewDidLoad()
    func didSelectDismiss()
    func didSelectMenu()
    func didSelectItem(_ model: CardControlDistributionItemViewModel?)
}

final class CardControlDistributionPresenter {
    weak var view: CardControlDistributionViewProtocol?
    private var viewModel: CardControlDistributionViewModel = CardControlDistributionViewModel()
    private let dependenciesResolver: DependenciesResolver

    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    private let suscriptions: [PullOfferLocation] = PullOffersLocationsFactoryEntity().suscriptionsM4M
    private var pullOfferCandidates: [PullOfferLocation: OfferEntity]?
}

private extension CardControlDistributionPresenter {
    var coordinator: CardControlDistributionCoordinatorProtocol {
        return self.dependenciesResolver.resolve(for: CardControlDistributionCoordinatorProtocol.self)
    }
    
    private var configuration: CardControlDistributionConfiguration {
        return self.dependenciesResolver.resolve(for: CardControlDistributionConfiguration.self)
    }
    
    private var getPullOffersCandidatesUseCase: GetPullOffersUseCase {
        self.dependenciesResolver.resolve()
    }
    
    func loadView() {
        guard let candidates = self.pullOfferCandidates, !candidates.isEmpty else {
            view?.addButtons(viewModel.items)
            return
        }
        candidates.forEach { (key, _ ) in
            viewModel.addItemLocated(key.stringTag)
        }
        view?.addButtons(viewModel.items)
    }
}

extension CardControlDistributionPresenter: CardControlDistributionPresenterProtocol {
    func viewDidLoad() {
        trackScreen()
        view?.showLoadingView { [weak self] in
            self?.loadOffer()
        }
    }
    
    func didSelectDismiss() {
        coordinator.dismiss()
    }
    
    func didSelectMenu() {
        coordinator.didSelectMenu()
    }
    
    func didSelectItem(_ model: CardControlDistributionItemViewModel?) {
        guard let model = model else { return }
        switch model.type {
        case .seeRecurringPaymentsList:
            trackEvent(.seeRecurringPaymentsList, parameters: [:])
            coordinator.goToCardSubscriptions(configuration.card)
        case .seeSubscriptions:
            guard let key = model.locationKey,
                  let locationKey = pullOfferCandidates?.location(key: key) else { return }
            trackEvent(.seeSubscriptions, parameters: [:])
            coordinator.goToEcommerceCard(locationKey.offer)
        }
    }
    
    func loadOffer() {
        Scenario(useCase: getPullOffersCandidatesUseCase,
                 input: GetPullOffersUseCaseInput(locations: suscriptions))
            .execute(on: dependenciesResolver.resolve())
            .onSuccess { [weak self] result in
                self?.view?.hideLoadingView()
                self?.pullOfferCandidates = result.pullOfferCandidates
                self?.loadView()
            }
            .onError { _ in
                self.view?.hideLoadingView()
                self.loadView()
            }
    }
}

extension CardControlDistributionPresenter: AutomaticScreenActionTrackable {
    var trackerPage: CardControlDistributionPage {
        CardControlDistributionPage()
    }
    var trackerManager: TrackerManager {
        self.dependenciesResolver.resolve(for: TrackerManager.self)
    }
}
