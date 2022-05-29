//
//  LastMovementsPresenter.swift
//  GlobalPosition
//
//  Created by Ignacio González Miró on 15/07/2020.
//

import CoreFoundationLib
import CoreDomain

protocol LastMovementsPresenterProtocol: AnyObject, MenuTextWrapperProtocol {
    var view: LastMovementsViewProtocol? { get set }
    func viewDidLoad()
    func viewWillAppear()
    func showMovementDetailForItem(_ item: UnreadMovementItem)
    func didSelectDismiss()
    func loadCandidatesOffersForViewModel(_ item: UnreadMovementItem)
}

class LastMovementsPresenter {
    
    weak var view: LastMovementsViewProtocol?
    
    let dependenciesResolver: DependenciesResolver
    var lastMovementsCoordinatorDelegate: LastMovementsCoordinatorProtocol {
        return dependenciesResolver.resolve(for: LastMovementsCoordinatorProtocol.self)
    }
        
    private var lastMovementViewModel: WhatsNewLastMovementsViewModel?
    private weak var globalPositionModuleCoordinator: GlobalPositionModuleCoordinatorDelegate? {
        return dependenciesResolver.resolve(for: GlobalPositionModuleCoordinatorDelegate.self)
    }
    private var baseURLProvider: BaseURLProvider {
        return dependenciesResolver.resolve(for: BaseURLProvider.self)
    }
    
    private var configuration: LastMovementsConfiguration {
        return dependenciesResolver.resolve(for: LastMovementsConfiguration.self)
    }

    private lazy var dataManager: WhatsNewDataManager = {
        return WhatsNewDataManager(resolver: dependenciesResolver)
    }()
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
}

extension LastMovementsPresenter: LastMovementsPresenterProtocol {
    func viewDidLoad() {
        self.loadUnreadMovements()
        self.trackScreen()
    }

    func viewWillAppear() {
        self.configureNavigationBar()
    }

    func showMovementDetailForItem(_ item: UnreadMovementItem) {
        dataManager.setReadMovementsForItem(item)
        switch item.type {
        case .account:
            guard let transaction = lastMovementViewModel?.accountTransactionFromItem(item, isFractionable: item.isFractionable),
                let transactionEntity = transaction.accountTransactionsWithAccountEntity?.accountTransactionEntity,
                let accountEntity = transaction.accountTransactionsWithAccountEntity?.accountEntity,
                let transactions = transaction.transactions else {
                return
            }
            globalPositionModuleCoordinator?.gotoAccountTransactionDetail(
                transactionEntity: transactionEntity,
                in: transactions,
                accountEntity: accountEntity
            )
        case .card:
            guard let transaction = lastMovementViewModel?.cardTransactionFromItem(item, isFractionable: item.isFractionable),
                let transactionEntity = transaction.cardTransactionsWithAccountEntity?.cardTransactionEntity,
                let cardEntity = transaction.cardTransactionsWithAccountEntity?.cardEntity,
                let transactions = transaction.transactions else {
                    return
            }
            globalPositionModuleCoordinator?.gotoCardTransactionDetail(transactionEntity: transactionEntity, in: transactions, cardEntity: cardEntity)
        }
    }
    
    func didSelectDismiss() {
        self.lastMovementsCoordinatorDelegate.dismiss()
    }
    
    func loadCandidatesOffersForViewModel(_ item: UnreadMovementItem) {
        let offerSelected: (OfferEntity?) -> Void = { offer in
            if let offer = offer {
                self.globalPositionModuleCoordinator?.didSelectOffer(offer)
            } else {
                self.showMovementDetailForItem(item)
            }
        }
        switch item.type {
        case .card:
            guard let transaction = lastMovementViewModel?.cardTransactionFromItem(item, isFractionable: item.isFractionable),
                  let entity = transaction.cardTransactionsWithAccountEntity else { return }
            self.crossSellingManager.loadCardCandidatesOffersForViewModel(
                item,
                transaction: entity,
                indexTag: item.crossSelling?.index ?? -1,
                completion: offerSelected)
        case .account:
            guard
                let transaction = lastMovementViewModel?.accountTransactionFromItem(item, isFractionable: item.isFractionable),
                let entity = transaction.accountTransactionsWithAccountEntity else { return }
            self.crossSellingManager.loadAccountCandidatesOffersForViewModel(
                item,
                transaction: entity,
                indexTag: item.crossSelling?.index ?? -1,
                completion: offerSelected)
        }
    }
    
    func loadCardCandidatesOffersForViewModel(_ item: UnreadMovementItem, transaction: CardTransactionWithCardEntity) {
        Scenario(useCase: cardTransactionPullOffersUseCase,
                 input: CardTransactionPullOffersConfigurationUseCaseInput(
                    transaction: transaction.cardTransactionEntity,
                    card: transaction.cardEntity,
                    specificLocations: PullOffersLocationsFactoryEntity().cards,
                    filterToApply: FilterCardLocation(location: CardsPullOffers.homeCrossSelling,
                                                      indexOffer: item.crossSelling?.index ?? -1)
                 ))
            .execute(on: self.dependenciesResolver.resolve())
            .onSuccess { [weak self] result in
                guard let candidates = result.pullOfferCandidates.location(key: CardsPullOffers.homeCrossSelling) else {
                    self?.showMovementDetailForItem(item)
                    return
                }
                self?.globalPositionModuleCoordinator?.didSelectOffer(candidates.offer)
            }
    }
    
    func loadAccountCandidatesOffersForViewModel(_ item: UnreadMovementItem, transaction: AccountTransactionWithAccountEntity) {
        Scenario(useCase: accountTransactionPullOffersUseCase,
                 input: AccountTransactionOfferConfigurationUseCaseInput(
                    account: transaction.accountEntity,
                    transaction: transaction.accountTransactionEntity,
                    locations: PullOffersLocationsFactoryEntity().cards,
                    specificLocations: PullOffersLocationsFactoryEntity().accountHomeCrossSelling,
                    filterToApply: FilterAccountLocation(location: AccountsPullOffers.homeCrossSelling,
                                                         indexOffer: item.crossSelling?.index ?? -1)
                ))
            .execute(on: self.dependenciesResolver.resolve())
            .onSuccess { [weak self] result in
                guard let candidates = result.pullOfferCandidates.location(key: CardsPullOffers.homeCrossSelling) else {
                    self?.showMovementDetailForItem(item)
                    return
                }
                self?.globalPositionModuleCoordinator?.didSelectOffer(candidates.offer)
            }
    }
}

private extension LastMovementsPresenter {
    var crossSellingManager: CrossSellingManager {
        return CrossSellingManager(dependenciesResolver: dependenciesResolver)
    }
    
    var accountTransactionPullOffersUseCase: AccountTransactionPullOfferConfigurationUseCase {
        self.dependenciesResolver.resolve(for: AccountTransactionPullOfferConfigurationUseCase.self)
    }
    
    var cardTransactionPullOffersUseCase: CardTransactionPullOfferConfigurationUseCase {
        self.dependenciesResolver.resolve(for: CardTransactionPullOfferConfigurationUseCase.self)
    }
    
    var getUnreadMovementsUseCase: GetUnreadMovementsUseCase {
        self.dependenciesResolver.resolve(firstTypeOf: GetUnreadMovementsUseCase.self)
    }
    
    func loadUnreadMovements() {
        if let viewModel = configuration.lastMovementesViewModel {
            self.buildLastMovements(viewModel)
        } else {
            getUnreadMovements()
        }
    }

    func getUnreadMovements() {
        let maxDaysWithoutSCA = Date().getDateByAdding(days: -89, ignoreHours: true)
        let input = GetUnreadMovementsUseCaseInput(startDate: maxDaysWithoutSCA,
                                                   limit: nil)
        Scenario(useCase: getUnreadMovementsUseCase,
                 input: input)
            .execute(on: self.dependenciesResolver.resolve())
            .onSuccess { [weak self] response in
                self?.getUnreadMovementsUseCaseSuccess(response)
            }
            .onError { [weak self]_ in
                self?.view?.showEmptyView()
            }
    }

    func getUnreadMovementsUseCaseSuccess(_ results: GetUnreadMovementsUseCaseOkOutput) {
        guard let baseUrl = baseURLProvider.baseURL else { return }
        let viewModel = WhatsNewLastMovementsViewModel(
            useCaseResponse: results,
            baseUrl: baseUrl)
        self.buildLastMovements(viewModel)
    }

    func buildLastMovements(_ viewModel: WhatsNewLastMovementsViewModel) {
        viewModel.rebuildModel(
            firstFourMovements: false,
            fractionableSection: self.configuration.fractionableSection)
        self.lastMovementViewModel = viewModel
        self.dataManager.setViewModel(viewModel)
        switch self.configuration.fractionableSection {
        case .fractionableCards:
            buildFractionableCardsView()
        default:
            self.view?.setViewModel(viewModel, configuration: self.configuration)
        }
    }

    func buildFractionableCardsView() {
        if let viewModel = self.lastMovementViewModel, viewModel.totalFractionableCards > 0 {
            self.view?.setViewModel(viewModel, configuration: self.configuration)
        } else {
            self.view?.showEmptyView()
        }
    }

    func configureNavigationBar() {
        let title: String
        switch self.configuration.fractionableSection {
        case .lastMovements:
            title = "toolbar_title_yourLastMovements"
        case .fundableAccounts, .fractionableCards:
            title = "toolbar_title_fractionalTransactions"
        }
        self.view?.configureNavigationBar(title)
    }
}

extension LastMovementsPresenter: AutomaticScreenTrackable {
    var trackerPage: LastMovementsListPage {
        let isLastMovements = configuration.fractionableSection == .lastMovements
        return LastMovementsListPage(isLastMovements: isLastMovements)
    }
    var trackerManager: TrackerManager {
        dependenciesResolver.resolve(for: TrackerManager.self)
    }
}
