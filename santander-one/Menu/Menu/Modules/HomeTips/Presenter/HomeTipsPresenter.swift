import CoreFoundationLib

protocol HomeTipsPresenterProtocol: MenuTextWrapperProtocol {
    var view: HomeTipsViewProtocol? { get set }
    func viewDidLoad()
    func didPressClose()
    func didPressDrawer()
    func didSelectOffer(_ offerId: String?)
    func didSelectAll(section: String, content: [HomeTipsViewModel])
}

final class HomeTipsPresenter {
    let dependenciesResolver: DependenciesResolver
    let dependenciesInjector: DependenciesInjector
    weak var view: HomeTipsViewProtocol?
    
    init(dependenciesResolver: DependenciesResolver, dependenciesInjector: DependenciesInjector) {
        self.dependenciesResolver = dependenciesResolver
        self.dependenciesInjector = dependenciesInjector
    }
    
    private var coordinator: HomeTipsCoordinatorProtocol {
        return self.dependenciesResolver.resolve(for: HomeTipsCoordinatorProtocol.self)
    }
    private var useCaseHandler: UseCaseHandler {
        self.dependenciesResolver.resolve(for: UseCaseHandler.self)
    }
    private var homeTipsUseCase: LoadHomeTipsUseCase {
        self.dependenciesResolver.resolve(for: LoadHomeTipsUseCase.self)
    }
    private var baseUrlProvider: BaseURLProvider {
        return self.dependenciesResolver.resolve(for: BaseURLProvider.self)
    }
    private var delegate: PublicMenuCoordinatorDelegate {
        return dependenciesResolver.resolve(for: PublicMenuCoordinatorDelegate.self)
    }
}

private extension HomeTipsPresenter {
    func loadHomeTips() {
        UseCaseWrapper(with: self.homeTipsUseCase, useCaseHandler: useCaseHandler, onSuccess: { [weak self] result in
            guard let entity = result.homeTips else { return }
            let viewModel = entity.map {
                HomeTipsCellViewModel(
                    title: $0.title,
                    content: $0.contents.map {
                        HomeTipsViewModel(title: localized($0.title ?? ""),
                                          description: localized($0.description ?? ""),
                                          icon: $0.icon,
                                          tag: localized($0.tag ?? ""),
                                          offerId: $0.offerId,
                                          keyWords: $0.keyWords,
                                          baseUrl: self?.baseUrlProvider.baseURL)
                    },
                    position: .zero)
            }
            self?.view?.showHomeTips(viewModel)
        }) { [weak self] _ in
            self?.view?.showHomeTips([])
        }
    }
}

extension HomeTipsPresenter: HomeTipsPresenterProtocol {
    func viewDidLoad() {
        self.loadHomeTips()
    }
    
    func didPressClose() {
        self.coordinator.close()
    }
    
    func didPressDrawer() {
        self.delegate.toggleSideMenu()
    }
    
    func didSelectOffer(_ offerId: String?) {
        let pullOfferInterpreter = self.dependenciesResolver.resolve(for: PullOffersInterpreter.self)
        guard let offerId = offerId, let offerDTO = pullOfferInterpreter.getOffer(offerId: offerId) else { return }
        self.delegate.didSelectOfferNodrawer(OfferEntity(offerDTO))
        self.trackEvent(.tipAccess, parameters: [.offerId: offerId])
    }
    
    func didSelectAll(section: String, content: [HomeTipsViewModel]) {
        self.trackEvent(.tipSeeAll, parameters: [:])
        let tipList: TipListCoordinatorProtocol = dependenciesResolver.resolve()
        let homeTipsConfig = HomeTipsConfiguration(section: section, tips: content)
        tipList.goToDetail(config: homeTipsConfig)
    }
}

extension HomeTipsPresenter: AutomaticScreenActionTrackable {
    var trackerManager: TrackerManager {
        return dependenciesResolver.resolve(for: TrackerManager.self)
    }
    
    var trackerPage: HomeTipsPage {
        return HomeTipsPage()
    }
}
