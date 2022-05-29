import Foundation
import CoreFoundationLib

protocol ComingFeaturesPresenterProtocol: AnyObject, MenuTextWrapperProtocol {
    var view: ComingFeaturesViewProtocol? { get set }
    func viewDidLoad()
    func didSelectMenu()
    func didSelectSearch()
    func didSelectDismiss()
    func didSelectTryFeatures()
    func didSelectedIndexChanged(_ index: Int)
    func didSelectNewFeature()
    func didSelectVoteButton(_ viewModel: ComingFeatureVoteViewModel)
    func didSelectOffer(_ offer: OfferEntity?)
    func comingFeatureViewModelUpdated(_ viewModel: ComingFeatureViewModel, with state: FeatureViewModelState)
    func implementedFeatureViewModelUpdated(_ viewModel: ImplementedFeatureViewModel, with state: FeatureViewModelState)
}

class ComingFeaturesPresenter {
    
    weak var view: ComingFeaturesViewProtocol?
    let dependenciesResolver: DependenciesResolver
    private var viewModel: FeaturesViewModel?
    private var selectedIndex = 0
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.viewModel = nil
    }
    
    private var coordinatorDelegate: ComingFeaturesCoordinatorDelegate {
        self.dependenciesResolver.resolve(for: ComingFeaturesCoordinatorDelegate.self)
    }
    
    private var getAllComingFeatures: GetAllComingFeaturesUseCase {
        return dependenciesResolver.resolve(for: GetAllComingFeaturesUseCase.self)
    }
    
    private var voteComingFeature: VoteComingFeatureUseCase {
        return dependenciesResolver.resolve(for: VoteComingFeatureUseCase.self)
    }
    
    private var pullOfferUseCase: GetPullOffersIdUseCase {
        return self.dependenciesResolver.resolve(for: GetPullOffersIdUseCase.self)
    }
    
    private var offers: [OfferEntity] = []
    
    private var useCaseHandler: UseCaseHandler {
        return self.dependenciesResolver.resolve(for: UseCaseHandler.self)
    }
    
    private var newIdeaOptinator: OpinatorInfoRepresentable {
        return RegularOpinatorInfoEntity(path: "appnew-proximamente")
    }
}

extension ComingFeaturesPresenter {
    private func executeUseCaseGetAllComingFeatures() {
        UseCaseWrapper(
            with: self.getAllComingFeatures.setRequestValues(requestValues: ()),
            useCaseHandler: self.dependenciesResolver.resolve(for: UseCaseHandler.self),
            onSuccess: { [weak self] result in
                let offerIds = self?.getOfferIds(from: result)
                self?.loadPullOffers(from: offerIds ?? [], {
                    self?.setViewModels(result)
                })
            })
    }
    
    private func getOfferIds(from result: GetAllComingFeaturesUseCaseOkOutput) -> [String] {
        var offersIds: [String] = []
        result.comingFeatures.forEach { entity in
            if let offer = entity.offerPayLoad {
                offersIds.append(offer.offerId)
            }
        }
        result.implementedFeatures.forEach { entity in
            if let offer = entity.offerPayLoad {
                offersIds.append(offer.offerId)
            }
        }
        return offersIds
    }
    
    private func loadPullOffers(from offers: [String], _ completion: @escaping() -> Void) {
        UseCaseWrapper(
            with: self.pullOfferUseCase.setRequestValues(requestValues: GetPullOffersIdUseCaseInput(offers: offers)),
            useCaseHandler: useCaseHandler,
            onSuccess: { [weak self] result in
                self?.offers = result.pullOfferCandidates
                completion()
            }, onError: {_ in
                completion()
            }
        )
    }
    
    private func setViewModels(_ data: GetAllComingFeaturesUseCaseOkOutput) {
        let comingFeatureViewModels = self.getComingFeatures(data.comingFeatures)
        let implementedFeatureViewModelss = self.getImplementedFeatures(data.implementedFeatures)
        let viewModel = FeaturesViewModel(comingFeatureViewModels: comingFeatureViewModels, implementedFeatureViewModels: implementedFeatureViewModelss)
        self.viewModel = viewModel
        guard let type = FeatureDataSourceType(rawValue: self.selectedIndex) else { return }
        self.view?.showFeatures(from: type, viewModel: viewModel)
    }
    
    private func getComingFeatures(_ newComingFeatures: [ComingFeatureEntity]) -> [ComingFeatureViewModel] {
        var comingFeatures: [ComingFeatureViewModel] = []
        newComingFeatures.forEach { entity in
            if let months = entity.date.months(from: Date()) {
                if months >= 0 {
                    let viewModel = self.getComingFeatureViewModel(from: entity)
                    comingFeatures.append(viewModel)
                }
            }
        }
        return comingFeatures
    }
    
    private func getImplementedFeatures(_ newImplementedFeatures: [ImplementedFeatureEntity]) -> [ImplementedFeatureViewModel] {
        var implementedFeatures: [ImplementedFeatureViewModel] = []
        newImplementedFeatures.forEach { entity in
            let viewModel = self.getImplementedFeatureViewModel(from: entity)
            implementedFeatures.append(viewModel)
        }
        return implementedFeatures
    }
    
    private func getComingFeatureViewModel(from entity: ComingFeatureEntity) -> ComingFeatureViewModel {
        let offerViewModel: FeatureOfferViewModel? = self.getOfferViewModel(from: entity.offerPayLoad)
        let viewModel = ComingFeatureViewModel(
            entity: entity,
            offer: offerViewModel,
            description: ComingFeatureDescriptionViewModel(entity: entity, dependenciesResolver: self.dependenciesResolver),
            vote: ComingFeatureVoteViewModel(entity: entity),
            state: offerViewModel != nil ? .initial : .withoutOffer
        )
        return viewModel
    }
    
    private func getImplementedFeatureViewModel(from entity: ImplementedFeatureEntity) -> ImplementedFeatureViewModel {
        let offerViewModel: FeatureOfferViewModel? = self.getOfferViewModel(from: entity.offerPayLoad)
        let viewModel = ImplementedFeatureViewModel(
            entity: entity,
            offer: offerViewModel,
            description: ImplementedFeatureDescriptionViewModel(entity: entity, dependenciesResolver: self.dependenciesResolver),
            state: offerViewModel != nil ? .initial : .withoutOffer
        )
        return viewModel
    }
    
    private func getOfferViewModel(from offerPayload: OfferPayLoad?) -> FeatureOfferViewModel? {
        guard let offerPayload = offerPayload else { return nil }
        return self.offer(from: offerPayload).map {
            FeatureOfferViewModel(offerEntity: $0, payload: offerPayload, dependenciesResolver: self.dependenciesResolver)
        }
    }
    
    private func offer(from offerPayload: OfferPayLoad) -> OfferEntity? {
        guard
            self.offers.contains(where: { $0.id == offerPayload.offerId }),
            let offer = self.offers.filter({ $0.id == offerPayload.offerId }).first
        else {
            return nil
        }
        return offer
    }
    
    private func executeVoteComingFeatureUseCase(_ entity: ComingFeatureEntity) {
        self.trackEvent(.vote, parameters: [.ideaIdentifier: entity.identifier])
        UseCaseWrapper(
            with: self.voteComingFeature.setRequestValues(requestValues: VoteComingFeatureUseCaseInput(idea: entity)),
            useCaseHandler: dependenciesResolver.resolve(for: UseCaseHandler.self)
        )
    }
    
    private func selectedIndexChanged(_ newIndex: Int) {
        self.selectedIndex = newIndex
        guard let viewModel = self.viewModel else { return }
        guard let type = FeatureDataSourceType(rawValue: newIndex) else { return }
        self.view?.showFeatures(from: type, viewModel: viewModel)
    }
}

extension ComingFeaturesPresenter: ComingFeaturesPresenterProtocol {
    func viewDidLoad() {
        self.view?.showLoading { [weak self] in
            self?.executeUseCaseGetAllComingFeatures()
            self?.view?.dismissLoading()
            self?.trackScreen()
        }
    }
    
    func didSelectMenu() {
        self.coordinatorDelegate.didSelectMenu()
    }
    
    func didSelectSearch() {
        self.coordinatorDelegate.didSelectSearch()
    }
    
    func didSelectDismiss() {
        self.coordinatorDelegate.didSelectDismiss()
    }
    
    func didSelectTryFeatures() {
        trackEvent(.tryNews, parameters: [:])
        self.coordinatorDelegate.didSelectTryFeatures()
    }
    
    func didSelectedIndexChanged(_ index: Int) {
        self.selectedIndexChanged(index)
    }
    
    func didSelectNewFeature() {
        trackEvent(.addIdea, parameters: [:])
        self.coordinatorDelegate.didSelectNewFeature(withOpinator: newIdeaOptinator)
    }
    
    func didSelectVoteButton(_ viewModel: ComingFeatureVoteViewModel) {
        self.executeVoteComingFeatureUseCase(viewModel.entity)
    }
    
    func didSelectOffer(_ offer: OfferEntity?) {
        self.coordinatorDelegate.didSelectOffer(offer)
    }
    
    func comingFeatureViewModelUpdated(_ viewModel: ComingFeatureViewModel, with state: FeatureViewModelState) {
        guard
            let type = FeatureDataSourceType(rawValue: self.selectedIndex),
            let featuresViewModel = self.viewModel?.updating(comingFeatureViewModel: ComingFeatureViewModel(from: viewModel, updating: state))
        else {
            return
        }
        self.viewModel = featuresViewModel
        self.view?.update(from: type, viewModel: featuresViewModel)
    }
    
    func implementedFeatureViewModelUpdated(_ viewModel: ImplementedFeatureViewModel, with state: FeatureViewModelState) {
        guard
            let type = FeatureDataSourceType(rawValue: self.selectedIndex),
            let featuresViewModel = self.viewModel?.updating(implementedFeatureViewModel: ImplementedFeatureViewModel(from: viewModel, updating: state))
        else {
            return
        }
        self.viewModel = featuresViewModel
        self.view?.update(from: type, viewModel: featuresViewModel)
    }
}

extension ComingFeaturesPresenter: AutomaticScreenActionTrackable {
    
    var trackerPage: ComingFeaturesPage {
        ComingFeaturesPage()
    }
    
    var trackerManager: TrackerManager {
        return dependenciesResolver.resolve(for: TrackerManager.self)
    }
}
