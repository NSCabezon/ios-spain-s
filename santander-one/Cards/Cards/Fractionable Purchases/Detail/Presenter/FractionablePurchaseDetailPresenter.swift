import CoreFoundationLib
import UI

protocol FractionablePurchaseDetailPresenterProtocol {
    var view: FractionablePurchaseDetailViewProtocol? { get set }
    func viewDidLoad()
    func didSelectBack()
    func didSelectClose()
    func didSelectTransaction(_ viewModel: FractionablePurchaseDetailViewModel)
    func scrollViewDidEndDecelerating()
    func didSelectInExpandableCollapsableButton(_ state: ResizableState)
}

final class FractionablePurchaseDetailPresenter {
    weak var view: FractionablePurchaseDetailViewProtocol?
    private let dependenciesResolver: DependenciesResolver
    private var carouselViewModel: FractionablePurchaseDetailCarouselViewModel?
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
}

private extension FractionablePurchaseDetailPresenter {
    var coordinator: FractionablePurchaseDetailCoordinatorProtocol {
        return self.dependenciesResolver.resolve(for: FractionablePurchaseDetailCoordinatorProtocol.self)
    }
    var configuration: FractionablePurchaseDetailConfiguration {
        return self.dependenciesResolver.resolve(for: FractionablePurchaseDetailConfiguration.self)
    }
    var useCaseHandler: UseCaseHandler {
        return self.dependenciesResolver.resolve(for: UseCaseHandler.self)
    }
    var fractionablePruchaseDetailUseCase: GetFractionablePurchaseDetailUseCase {
        return self.dependenciesResolver.resolve(for: GetFractionablePurchaseDetailUseCase.self)
    }
    
    func loadData(_ input: FractionablePurchaseDetailUseCaseInput) {
        Scenario(useCase: fractionablePruchaseDetailUseCase, input: input)
            .execute(on: self.useCaseHandler)
            .onSuccess { [weak self] output in
                guard let self = self else { return }
                self.loadNewMovementDetail(output.movementDetail)
            }
            .onError { [weak self] _ in
                guard let self = self else { return }
                self.view?.showEmptyView()
                self.updateOutputCarouselWithError()
            }
    }
    
    // MARK: Colapsable Carousel methods
    func loadNewMovementDetail(_ outputMovement: FinanceableMovementDetailEntity) {
        guard let movementUpdated = self.getUpdatedCarouselViewModel(outputMovement) else {
            return
        }
        movementUpdated.itemStatus = .success
        self.view?.updateCollapsableCarousel(movementUpdated)
        self.view?.addEasyPaymentAmortizations(movementUpdated.amortizations)
    }
    
    func getUpdatedCarouselViewModel(_ outputMovement: FinanceableMovementDetailEntity) -> FractionablePurchaseDetailViewModel? {
        guard let updatedCarouselViewModel = self.carouselViewModel else { return nil }
        let movementUpdated = updatedCarouselViewModel.financeableMovementEntityList.filter {
            $0.financeableMovementEntity.identifier == updatedCarouselViewModel.selectedFinanceableMovementEntity.financeableMovementEntity.identifier
        }.first
        movementUpdated?.financeableMovementDetailEntity = outputMovement
        return movementUpdated
    }
    
    func createCarouselViewModel() {
        let detailEntityList: [FractionablePurchaseDetailViewModel] =
            self.configuration.movements.map({
                let timeManager = self.dependenciesResolver.resolve(for: TimeManager.self)
                return FractionablePurchaseDetailViewModel($0, detailEntity: nil, cardEntity: self.configuration.card, timeManager: timeManager)
            })
        guard let movementSelected = detailEntityList.filter({ $0.financeableMovementEntity.identifier == self.configuration.movementID }).first else { return }
        movementSelected.itemStatus = .success
        let viewModel = FractionablePurchaseDetailCarouselViewModel(movementSelected, detailEntityList: detailEntityList)
        self.carouselViewModel = viewModel
        self.view?.setCollapsableCarousel(viewModel)
    }
    
    func updateOutputCarouselWithError() {
        guard let updatedCarouselViewModel = self.carouselViewModel else {
            return
        }
        let movementUpdated = updatedCarouselViewModel.financeableMovementEntityList.filter {
            $0.financeableMovementEntity.identifier == updatedCarouselViewModel.selectedFinanceableMovementEntity.financeableMovementEntity.identifier
        }.first
        guard let movements = movementUpdated else {
            return
        }
        movements.itemStatus = .error
        self.view?.updateCollapsableCarousel(movements)
    }
}

extension FractionablePurchaseDetailPresenter: FractionablePurchaseDetailPresenterProtocol {
    func viewDidLoad() {
        self.createCarouselViewModel()
        view?.showLoadingView()
        let input = FractionablePurchaseDetailUseCaseInput(movID: self.configuration.movementID, pan: self.configuration.card.pan)
        self.loadData(input)
        self.trackScreen()
    }
    
    func didSelectBack() {
        coordinator.dismiss()
    }
    
    func didSelectClose() {
        coordinator.dismiss()
    }
    
    // MARK: - Collapsable Carousel methods
    func didSelectInExpandableCollapsableButton(_ state: ResizableState) {
        guard let viewModels = self.carouselViewModel else { return }
        let itemSelected = viewModels.selectedFinanceableMovementEntity
        switch state {
        case .colapsed:
            itemSelected.carouselState = .expanded
        case .expanded:
            itemSelected.carouselState = .colapsed
        }
        itemSelected.itemStatus = .success
        view?.updateCollapsableCarousel(itemSelected)
        self.trackEvent(.expandable, parameters: [:])
    }
    
    func didSelectTransaction(_ viewModel: FractionablePurchaseDetailViewModel) {
        self.carouselViewModel?.selectedFinanceableMovementEntity = viewModel
        self.carouselViewModel?.financeableMovementEntityList.forEach { $0.carouselState = .colapsed }
        self.carouselViewModel?.selectedFinanceableMovementEntity.itemStatus = .loading
        let movementIdentifier = self.carouselViewModel?.selectedFinanceableMovementEntity.financeableMovementEntity.identifier ?? ""
        let input = FractionablePurchaseDetailUseCaseInput(movID: movementIdentifier, pan: self.configuration.card.pan)
        view?.showLoadingView()
        loadData(input)
    }
    
    func scrollViewDidEndDecelerating() {
        self.trackEvent(.swipe, parameters: [:])
    }
}

extension FractionablePurchaseDetailPresenter: AutomaticScreenActionTrackable {
    var trackerPage: EasyPayFractionableDetailPage {
        EasyPayFractionableDetailPage()
    }
    var trackerManager: TrackerManager {
        self.dependenciesResolver.resolve(for: TrackerManager.self)
    }
}
