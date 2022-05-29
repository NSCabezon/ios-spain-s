//
//  FinancingDistributionPresenter.swift
//  Menu
//
//  Created by Boris Chirino Fernandez on 28/08/2020.
//

import CoreFoundationLib
import UI

protocol FinancingDistributionPresenterProtocol: AnyObject {
    var view: FinancingDistributionViewProtocol? { get set }
    func viewDidLoad()
    func viewDidAppear()
    func loadLastContributionsData()
    func didSelectedOffer(_ viewModel: OfferBannerViewModel?)
    func didTapInFractionatedPurchase(_ viewModel: FractionatePurchasesCarouselViewModel)
    func didTapInSeeMoreFractionatedPurchases()
    func didSwipeCollectionView()
}

final class FinancingDistributionPresenter {
    weak var view: FinancingDistributionViewProtocol?
    let dependenciesResolver: DependenciesResolver
    private var pullOfferCandidates: [PullOfferLocation: OfferEntity]?
    private let locations: [PullOfferLocation] = PullOffersLocationsFactoryEntity().financingDistribution
    private var maxFractionableItems = 7
    lazy var getAllFractionablePurchasesWithDetailSuperUseCase: GetAllFractionablePurchasesWithDetailSuperUseCase = {
        let superUseCase = self.dependenciesResolver.resolve(for: GetAllFractionablePurchasesWithDetailSuperUseCase.self)
        superUseCase.delegate = self
        return superUseCase
    }()
    private var fractionatedMovements: [FinanceableMovementEntity] = []
    private var carouselViewModels: [FractionatePurchasesCarouselViewModel] = []
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
}

extension FinancingDistributionPresenter: FinancingDistributionPresenterProtocol {
    
    func viewDidLoad() {
        self.view?.showLoading()
        self.loadLastContributionsData()
    }
    
    func viewDidAppear() {
        trackScreen()
    }
    
    func loadLastContributionsData() {
        Scenario(useCase: self.getLastContributionsUseCase)
            .execute(on: self.useCaseHandler)
            .onSuccess { [weak self] output in
                guard let self = self else { return }
                let viewModel = LastContributionsViewModel(loans: output.lastContributions.loans, cards: output.lastContributions.cards)
                self.view?.loadLastContributionsView(viewModel)
                self.loadFinancingDistributionData()
                self.loadOffers()
            }
            .onError { [weak self] _ in
                guard let self = self else { return }
                self.view?.showFractionatedPurchasesCarouselEmptyView()
                self.view?.dismissLoading()
            }
            .finally {
                self.showFractionatedPurchasesCarouselIfNeeded()
            }
    }
    
    func didSelectedOffer(_ viewModel: OfferBannerViewModel?) {
        self.coordinatorDelegate.didSelectOffer(viewModel?.offer)
    }
    
    func didTapInFractionatedPurchase(_ viewModel: FractionatePurchasesCarouselViewModel) {
        guard let card = viewModel.cardEntity,
              let movementViewModel = viewModel.movementViewModel,
              let financeableMovement = viewModel.financeableMovement else {
            return
        }
        self.coordinatorDelegate.didSelectPurchase(
            card,
            movementId: movementViewModel.identifier,
            movements: [financeableMovement]
        )
        trackEvent(.clickDetail)
        
    }
    
    func didTapInSeeMoreFractionatedPurchases() {
        self.view?.showFractionatedPurchasesCarouselLoadingView()
        self.maxFractionableItems += self.maxFractionableItems
        var updatedCarouselViewModels = Array(self.carouselViewModels.prefix(self.maxFractionableItems))
        if self.carouselViewModels.count > updatedCarouselViewModels.count {
            let seeMoreItem = self.setSeeMoreItemInFractionatedPurchaseCarousel()
            updatedCarouselViewModels.insert(seeMoreItem, at: updatedCarouselViewModels.count)
        }
        self.view?.showFractionatedPurchasesCarouselView(updatedCarouselViewModels, numOfItems: self.carouselViewModels.count)
        trackEvent(.viewMorePayments)
    }
    
    func didSwipeCollectionView() {
        trackEvent(.swipeCarousel)
    }
}

private extension FinancingDistributionPresenter {
    var coordinatorDelegate: FinancingCoordinatorDelegate {
        self.dependenciesResolver.resolve(for: FinancingCoordinatorDelegate.self)
    }
    var getPullOffersCandidatesUseCase: GetPullOffersUseCase {
        self.dependenciesResolver.resolve()
    }
    var useCaseHandler: UseCaseHandler {
        return self.dependenciesResolver.resolve(for: UseCaseHandler.self)
    }
    var financialDistributionUseCase: FinancingDistributionUseCase {
        dependenciesResolver.resolve(for: FinancingDistributionUseCase.self)
    }
    var getLastContributionsUseCase: LastContributionsUseCase {
        self.dependenciesResolver.resolve(for: LastContributionsUseCase.self)
    }
    var getFractionablePurchasesUseCase: GetFractionablePurchasesUseCase {
        self.dependenciesResolver.resolve(for: GetFractionablePurchasesUseCase.self)
    }
    var getFractionablePurchaseDetailUseCase: GetFractionablePurchaseDetailUseCase {
        self.dependenciesResolver.resolve(for: GetFractionablePurchaseDetailUseCase.self)
    }
    var timeManager: TimeManager {
        self.dependenciesResolver.resolve(for: TimeManager.self)
    }
    var urlProvider: BaseURLProvider {
        self.dependenciesResolver.resolve(for: BaseURLProvider.self)
    }
    
    func loadFinancingDistributionData() {
        Scenario(useCase: financialDistributionUseCase)
            .execute(on: self.useCaseHandler)
            .onSuccess { [weak self] result in
                guard let self = self else { return }
                let viewModel = FinanceDistributionViewModel(distributionEntity: result.financialAgregatorEntity)
                let containsProductsGroup = result.productsGroupCount != 0
                let containsFinancialAgregatorItems = result.financialAgregatorEntity.items.count != 0
                let viewState: ViewState<FinanceDistributionViewModel> = containsProductsGroup
                    && containsFinancialAgregatorItems
                    ? .filled(viewModel)
                    : .empty
                self.view?.viewState = viewState
            }
            .onError { [weak self] _ in
                self?.view?.viewState = .empty
            }
            .finally {
                self.view?.dismissLoading()
            }
    }
    
    func loadOffers() {
        let input = GetPullOffersUseCaseInput(locations: self.locations)
        Scenario(useCase: getPullOffersCandidatesUseCase, input: input)
            .execute(on: self.useCaseHandler)
            .onSuccess { [weak self] result in
                guard let self = self else { return }
                self.pullOfferCandidates = result.pullOfferCandidates
                self.showLocation()
            }
    }
    
    func showLocation() {
        guard let offersCandidates = self.pullOfferCandidates else {
            return
        }
        offersCandidates.forEach { (location, offerEntity) in
            if self.locations.first(where: {$0.stringTag == location.stringTag}) != nil {
                let viewModel = OfferBannerViewModel(entity: offerEntity)
                self.view?.loadOfferBanner(viewModel)
            }
        }
    }
    
    // MARK: - FractionatedPurchases Carousel
    func showFractionatedPurchasesCarouselIfNeeded() {
        let appConfig = self.dependenciesResolver.resolve(for: AppConfigRepositoryProtocol.self)
        guard let isEnabledEasyPayInstallmentsCarousel = appConfig.getBool("enabledEasyPayInstallmentsCarousel"),
              isEnabledEasyPayInstallmentsCarousel,
              let numberItemsEasyPayCarouselZF = appConfig.getInt("numberItemsEasyPayCarouselZF") else {
            self.view?.hiddeFractionatedPurchasesCarousel()
            return
        }
        self.view?.showFractionatedPurchasesCarouselLoadingView()
        self.maxFractionableItems = numberItemsEasyPayCarouselZF
        self.getAllFractionablePurchasesWithDetailSuperUseCase.execute()
    }
    
    func updateFractionatedMovementsList(_ fractionablePurchases: [GetFractionablePurchaseWithDetailOutput]) {
        fractionablePurchases.forEach { (item) in
            self.fractionatedMovements.append(item.financiableMovement)
        }
    }
    
    func removeFractionatedMovementList() {
        self.fractionatedMovements.removeAll()
    }
    
    func createFractionatedPurchasesCarouselViewModel(_ fractionablePurchases: [GetFractionablePurchaseWithDetailOutput]) -> [FractionatePurchasesCarouselViewModel] {
        let viewModels: [FractionatePurchasesCarouselViewModel] = fractionablePurchases.compactMap { (output) in
            return FractionatePurchasesCarouselViewModel(
                baseUrl: urlProvider.baseURL ?? "",
                cardEntity: output.cardEntity,
                financeableMovement: output.financiableMovement,
                financeableMovementDetail: output.financiableMovementDetail,
                timeManager: self.timeManager,
                carouselItemType: .item
            )
        }
        self.carouselViewModels = viewModels
        let list = viewModels.prefix(self.maxFractionableItems)
        return Array(list)
    }
    
    func setSeeMoreItemInFractionatedPurchaseCarousel() -> FractionatePurchasesCarouselViewModel {
        return FractionatePurchasesCarouselViewModel(
            baseUrl: "",
            cardEntity: nil,
            financeableMovement: nil,
            financeableMovementDetail: nil,
            timeManager: nil,
            carouselItemType: .seeMoreItems
        )
    }
    
    func handleCarouselSeeMoreItemIfNeeded(_ fractionablePurchases: [GetFractionablePurchaseWithDetailOutput], viewModels: [FractionatePurchasesCarouselViewModel]) {
        let list = viewModels.prefix(self.maxFractionableItems)
        var carouselViewModels = Array(list)
        if fractionablePurchases.count > carouselViewModels.count {
            let seeMoreItem = self.setSeeMoreItemInFractionatedPurchaseCarousel()
            carouselViewModels.insert(seeMoreItem, at: carouselViewModels.count)
        }
        self.view?.showFractionatedPurchasesCarouselView(carouselViewModels, numOfItems: self.carouselViewModels.count)
    }
}

// MARK: - GetAllFractionablePurchasesWithDetail SuperUseCaseDelegate
extension FinancingDistributionPresenter: GetAllFractionablePurchasesWithDetailSuperUseCaseDelegate {
    func didFinishGetAllPurchasesSuccessfully(with fractionablePurchases: [GetFractionablePurchaseWithDetailOutput]) {
        guard !fractionablePurchases.isEmpty else {
            self.view?.showFractionatedPurchasesCarouselEmptyView()
            return
        }
        self.updateFractionatedMovementsList(fractionablePurchases)
        let viewModels = self.createFractionatedPurchasesCarouselViewModel(fractionablePurchases)
        self.handleCarouselSeeMoreItemIfNeeded(fractionablePurchases, viewModels: viewModels)
    }
    
    func didFinishWithError(_ error: String?) {
        self.removeFractionatedMovementList()
        self.view?.dismissLoading()
        self.view?.showFractionatedPurchasesCarouselEmptyView()
    }
}

extension FinancingDistributionPresenter: AutomaticScreenActionTrackable {
    var trackerPage: FinancingDistributionPage {
        return FinancingDistributionPage()
    }
    var trackerManager: TrackerManager {
        return dependenciesResolver.resolve(for: TrackerManager.self)
    }
}
