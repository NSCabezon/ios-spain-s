//
//  FractionablePurchasesPresenter.swift
//  Cards
//
//  Created by César González Palomino on 15/02/2021.
//

import CoreFoundationLib

protocol FractionablePurchasesPresenterProtocol: MenuTextWrapperProtocol {
    var view: FractionablePurchasesViewProtocol? { get set }
    func viewDidLoad()
    func didSelectMenu()
    func didSelectDismiss()
    func didSelectMovement(_ movement: FractionableMovementViewModel?)
    func didSelectElegiblePurchase(_ purchase: FractionableMovementCollectionViewModel)
    func showEndedMovements()
    func showAllFractionableMovements()
    func didSelectViewMore()
    func didSwipeFractionableCarousel()
}

final class FractionablePurchasesPresenter {
    private struct Movements {
        var fractionated: [FinanceableMovementEntity] = []
        var finished: [FinanceableMovementEntity] = []
        var fractionable: [FinanceableMovementEntity] = []
    }
    weak var view: FractionablePurchasesViewProtocol?
    internal let dependenciesResolver: DependenciesResolver
    private var movements = FractionablePurchasesPresenter.Movements()

    private var configuration: FractionablePurchasesConfiguration {
        return dependenciesResolver.resolve()
    }

    private var coordinator: FractionablePurchasesCoordinatorProtocol {
        return dependenciesResolver.resolve(for: FractionablePurchasesCoordinatorProtocol.self)
    }

    private var useCase: GetFractionablePurchasesUseCase {
        dependenciesResolver.resolve(for: GetFractionablePurchasesUseCase.self)
    }

    private var baseURLProvider: BaseURLProvider {
        return dependenciesResolver.resolve(for: BaseURLProvider.self)
    }

    private var timeManager: TimeManager {
        return dependenciesResolver.resolve(for: TimeManager.self)
    }
    private let maxFractionableItems = 7
    lazy var getAllFractionablePurchasesSuperUseCase: GetAllFractionablePurchasesSuperUseCase = {
        let superUseCase = self.dependenciesResolver.resolve(for: GetAllFractionablePurchasesSuperUseCase.self)
        superUseCase.delegate = self
        return superUseCase
    }()
    
    // MARK: - Initializers
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
}

extension FractionablePurchasesPresenter: FractionablePurchasesPresenterProtocol {
    func viewDidLoad() {
        setHeaderCard()
        loadList()
    }

    func didSelectMenu() {
        self.coordinator.didSelectMenu()
    }

    func didSelectDismiss() {
        self.coordinator.didSelectDismiss()
    }

    func showEndedMovements() {
        trackEvent(.showEnded)
    }

    func showAllFractionableMovements() { }

    func didSelectMovement(_ movement: FractionableMovementViewModel?) {
        var newMovementList: [FinanceableMovementEntity] = []
        self.movements.fractionated.forEach { (entity) in
            newMovementList.append(entity)
        }
        self.movements.finished.forEach { (entity) in
            newMovementList.append(entity)
        }
        trackEvent(.goDetail)
        coordinator.didSelectPurchase(configuration.card, movement: movement?.identifier ?? "", movements: newMovementList)
    }

    func didSelectElegiblePurchase(_ purchase: FractionableMovementCollectionViewModel) {
        guard let transaction = purchase.transactionEntity else { return }
        self.trackEvent(.goToDetailFractionable)
        coordinator.goToTransaction(transaction, card: configuration.card)
    }

    func didSwipeFractionableCarousel() {
        self.trackEvent(.swipeFractionable)
    }

    func didSelectViewMore() {
        coordinator.didSelectViewMore()
    }
}

extension FractionablePurchasesPresenter: AutomaticScreenTrackable, AutomaticScreenActionTrackable {
    var trackerManager: TrackerManager {
        return dependenciesResolver.resolve(for: TrackerManager.self)
    }

    var trackerPage: EasyPayFractionablePage {
        return EasyPayFractionablePage()
    }

    func trackEvent(_ action: EasyPayFractionablePage.Action, parameters: [String: String] = [:]) {
        trackerManager.trackEvent(screenId: trackerPage.page,
                                  eventId: action.rawValue,
                                  extraParameters: parameters)
    }
}

private extension FractionablePurchasesPresenter {
    func getFractionatedMovementsScenario() -> Scenario<FractionablePurchasesUseCaseInput,
                                                        FractionablePurchasesUseCaseOkOutput,
                                                        StringErrorOutput> {
        let configuration: FractionablePurchasesConfiguration = dependenciesResolver.resolve()
        let dateTo = timeManager.toString(date: Date(), outputFormat: .yyyyMMdd, timeZone: .local)
        let dateFrom = timeManager.toString(date: Date(timeIntervalSince1970: 0), outputFormat: .yyyyMMdd)
        return Scenario(useCase: useCase,
                        input: FractionablePurchasesUseCaseInput(isEasyPay: true,
                                                                 pan: configuration.card.formattedPAN ?? "",
                                                                 dateFrom: dateFrom,
                                                                 dateTo: dateTo))
    }

    func getFinanciableMovementsScenario(_ output: FractionablePurchasesUseCaseOkOutput) -> Scenario<FractionablePurchasesUseCaseInput,
                                                                                                     FractionablePurchasesUseCaseOkOutput,
                                                                                                     StringErrorOutput> {
        let configuration: FractionablePurchasesConfiguration = dependenciesResolver.resolve()
        let sixtyDaysAgoDate = Date().startOfDay().getUtcDate()?.addDay(days: -60) ?? Date()
        let endDate = Date().startOfDay().getUtcDate() ?? Date()
        let dateTo = timeManager.toString(date: endDate, outputFormat: .yyyyMMdd, timeZone: .local)
        let dateFrom = timeManager.toString(date: sixtyDaysAgoDate, outputFormat: .yyyyMMdd)
        let input = FractionablePurchasesUseCaseInput(isEasyPay: false,
                                                      pan: configuration.card.formattedPAN ?? "",
                                                      dateFrom: dateFrom,
                                                      dateTo: dateTo)
        return Scenario(useCase: useCase,
                        input: input)
    }

    func loadList() {
        view?.showLoading(true)
        let sce1 = getFractionatedMovementsScenario()
        sce1.execute(on: dependenciesResolver.resolve())
            .onSuccess { [weak self] output in
                let movements = output.movements
                self?.movements.finished = movements.filter { $0.status == .settled }
                self?.movements.fractionated = movements.filter { $0.status == .pending }
            }
            .finally { [weak self] in
                self?.processResponse()
                self?.getAllFractionablePurchasesSuperUseCase.execute()
            }
    }

    func setHeaderCard() {
        let configuration: FractionablePurchasesConfiguration = dependenciesResolver.resolve()
        let card = configuration.card
        let cardImageURL = baseURLProvider.baseURL ?? ""
        let headerViewModel = FractionablePurchasesHeaderViewModel(
            cardName: card.alias ?? "",
            cardCode: card.shortContract,
            cardImageURL: cardImageURL + card.buildImageRelativeUrl(miniature: true),
            amountEntity: card.currentBalance)
        view?.setupHeaderWith(headerViewModel)
    }

    func processResponse() {
        let fractionated = movements.fractionated
        let finished = movements.finished
        if let fractionatedVM = createViewModelFrom(fractionated) {
            view?.showFractionatedMovements(fractionatedVM)
        }
        if let finishedVM = createViewModelFrom(finished) {
            view?.showSettledMovements(finishedVM)
        }
        if fractionated.isEmpty && finished.isEmpty {
            view?.showEmptyView()
        }
    }

    func createViewModelFrom(_ entities: [FinanceableMovementEntity]) -> [FractionableMovementViewModel]? {
        guard !entities.isEmpty else { return nil }
        let timeManager: TimeManager = self.dependenciesResolver.resolve(for: TimeManager.self)
        return entities.map {
            FractionableMovementViewModel(identifier: $0.identifier ?? "",
                                          operativeDate: timeManager.toString(date: $0.date,
                                                                              outputFormat: .dd_MMMM_YYYY) ?? "",
                                          name: $0.name ?? "",
                                          amount: $0.amount,
                                          pendingFees: $0.pendingFees,
                                          totalFees: $0.totalFees,
                                          addTapGesture: shouldAddTapGesture())
        }
    }
    
    func createFractionableViewModelFrom(_ entities: [FinanceableMovementEntity], card: CardEntity) -> [FractionableMovementCollectionViewModel] {
        guard !entities.isEmpty else { return [] }
        let fractionablePurchasesListViewModel = self.dependenciesResolver.resolve(for: FractionablePurchasesListViewModel.self)
        let timeManager: TimeManager = self.dependenciesResolver.resolve(for: TimeManager.self)
        let cardImageURL = baseURLProvider.baseURL ?? ""
        return entities.map {
                return FractionableMovementCollectionViewModel(date: (timeManager.toString(date: $0.date, outputFormat: .d_MMMM) ?? "").uppercased(),
                                                               name: ($0.name ?? "").camelCasedString,
                                                               amountEntity: $0.amount,
                                                               cardImageName: cardImageURL + card.buildImageRelativeUrl(miniature: true),
                                                               cardAlias: card.alias ?? "",
                                                               cardCode: card.shortContract,
                                                               transactionEntity: fractionablePurchasesListViewModel.cardTransaction(from: $0))
        }
    }

    func shouldAddTapGesture() -> Bool {
        guard let isEnablePurchaseDetail = self.dependenciesResolver.resolve(for: AppConfigRepositoryProtocol.self).getBool(FractionablePurchaseConstants.appConfigEnablePurchaseDetail),
              isEnablePurchaseDetail else {
            return false
        }
        return true
    }
}

extension FractionablePurchasesPresenter: GetAllFractionablePurchasesSuperUseCaseDelegate {
    func didFinishGetAllPurchasesSuccessfully(with fractionablePurchases: [GetAllFractionablePurchasesOutput]) {
        self.view?.showLoading(false)
        var fractionableVM: [FractionableMovementCollectionViewModel] = []
        let configuration: FractionablePurchasesConfiguration = self.dependenciesResolver.resolve()
        let currentCard = configuration.card
        let currentFinanciableMovements = fractionablePurchases.first(where: { output in
            output.getCardEntity() == currentCard
        })
        if let currentFinanciableMovements = currentFinanciableMovements {
            fractionableVM += self.createFractionableViewModelFrom(
                currentFinanciableMovements.getFinanceableMovements(),
                card: currentCard
            )
        }
        for fractionablePurchase in fractionablePurchases {
            if fractionableVM.count > self.maxFractionableItems {
                break
            }
            if fractionablePurchase.getCardEntity() == currentCard {
                continue
            }
            fractionableVM += self.createFractionableViewModelFrom(
                fractionablePurchase.getFinanceableMovements(),
                card: fractionablePurchase.getCardEntity()
            )
        }
        let list = fractionableVM.prefix(self.maxFractionableItems)
        self.view?.showFractionableMovements(Array(list))
    }
    
    func didFinishWithError(error: String?) {}
}
