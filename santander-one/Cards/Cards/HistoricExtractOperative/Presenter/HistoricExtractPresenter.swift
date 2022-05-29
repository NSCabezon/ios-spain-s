//
//  HistoricExtractPresenter.swift
//  Cards
//
//  Created by Ignacio González Miró on 16/11/2020.
//

import Operative
import CoreFoundationLib

protocol HistoricExtractPresenterProtocol: OperativeStepPresenterProtocol {
    var view: HistoricExtractViewProtocol? { get set }
    var isShoppingMapEnabled: Bool { get }
    var isExtractPdfEnabled: Bool { get }
    func viewDidLoad()
    func didTapInClose()
    func didSelectMonth(_ differenceBetweenMonths: Int, dateName: String)
    func didTapInShopMapPill()
    func didTapInPdfExtractPill()
}

extension HistoricExtractPresenterProtocol {
    var shouldShowProgressBar: Bool {
        false
    }
}

final class HistoricExtractPresenter {
    let dependenciesResolver: DependenciesResolver
    weak var view: HistoricExtractViewProtocol?
    var container: OperativeContainerProtocol?
    var isBackButtonEnabled: Bool = false
    var isCancelButtonEnabled: Bool = false
    var number: Int = 0
    var monthSelected: String = ""
    lazy var operativeData: HistoricExtractOperativeData = {
        guard let container = self.container else { fatalError() }
        return container.get()
    }()
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.monthSelected = self.dependenciesResolver.resolve(for: TimeManager.self).toString(date: Date(), outputFormat: .MMMM_YYYY) ?? ""
    }
}

extension HistoricExtractPresenter: HistoricExtractPresenterProtocol {
    var isShoppingMapEnabled: Bool {
        guard (operativeData.cardSettlementDetailEntity?.startDate != nil) && (operativeData.cardSettlementDetailEntity?.endDate != nil) else {
            return operativeData.isMultipleMapEnabled
        }
        return true
    }

    var isExtractPdfEnabled: Bool {
        return operativeData.card.isOwnerSuperSpeed
    }
    
    func viewDidLoad() {
        self.setupView()
        self.trackScreen()
    }
    
    // MARK: Actions
    func didTapInClose() {
        self.container?.stepFinished(presenter: self)
    }
    
    func didTapInShopMapPill() {
        self.trackEvent(.shoppingMap, parameters: [:])
        let card = operativeData.card
        guard let startDate = operativeData.cardSettlementDetailEntity?.startDate,
            let endDate = operativeData.cardSettlementDetailEntity?.endDate
            else {
                self.didSelectMapMultipleTransactions(card)
                return
        }
        let configurationMapType = CardMapTypeConfiguration.date(startDate: startDate, endDate: endDate)
        self.finishingCoordinator.goToMapView(card, type: configurationMapType)
    }
    
    func didTapInPdfExtractPill() {
        self.trackEvent(.extractPdf, parameters: [:])
        self.cardsHomeCoordinatorDelegate?.didSelectInExtractPdf(operativeData.card, selectedMonth: self.monthSelected)
    }

    func didSelectMonth(_ differenceBetweenMonths: Int, dateName: String) {
        self.trackEvent(.monthSelector, parameters: [:])
        self.monthSelected = dateName
        self.view?.showLoading()
        let useCase = historicExtractUseCase.setRequestValues(requestValues: GetHistoricExtractUseCaseInput(card: operativeData.card,
                                                                                                            differenceBetweenMonths: differenceBetweenMonths))
        let useCaseHandler = self.dependenciesResolver.resolve(for: UseCaseHandler.self)
        UseCaseWrapper(with: useCase, useCaseHandler: useCaseHandler, onSuccess: { [weak self] (result) in
            guard let strongSelf = self else { return }
            strongSelf.operativeData.settlementMovements = result.settlementMovementsList ?? []
            strongSelf.operativeData.cardSettlementDetailEntity = result.cardSettlementDetailEntity
            strongSelf.setTableViewModels()
            strongSelf.updateHeaderViewModel()
            strongSelf.view?.dismissLoading()
            }, onError: { (_) in
                self.view?.dismissLoading()
        })
    }
}

private extension HistoricExtractPresenter {
    var historicExtractUseCase: HistoricExtractUseCase {
        return self.dependenciesResolver.resolve(for: HistoricExtractUseCase.self)
    }
    var baseURLProvider: BaseURLProvider {
        return dependenciesResolver.resolve(for: BaseURLProvider.self)
    }
    var finishingCoordinator: HistoricExtractOperativeFinishingCoordinator {
        return dependenciesResolver.resolve(for: HistoricExtractOperativeFinishingCoordinator.self)
    }
    var cardsHomeCoordinatorDelegate: CardsHomeModuleCoordinatorDelegate? {
        return self.dependenciesResolver.resolve(for: CardsHomeModuleCoordinatorDelegate.self)
    }
    
    func setupView() {
        self.setHeaderViewModel()
        self.setTableViewModels()
    }
    
    func setHeaderViewModel() {
        guard let headerViewModel = getHeaderViewModel() else {
            return
        }
        self.view?.setHeaderViewModel(headerViewModel)
    }

    func updateHeaderViewModel() {
        guard let headerViewModel = getHeaderViewModel() else {
            return
        }
        self.view?.updateHeaderView(headerViewModel)
    }
    
    func getHeaderViewModel() -> NextSettlementViewModel? {
        guard let settlementMovementsOwnerPan = operativeData.ownerPan, let settlementMovementsScaDate = operativeData.scaDate, let detailEntity = operativeData.cardSettlementDetailEntity else {
            return nil
        }
        let panMovements: [NextSettlementMovementWithPANViewModel] = [NextSettlementMovementWithPANViewModel(operativeData.card, movementsEntity: operativeData.settlementMovements)]
        let configuration = NextSettlementConfiguration(card: operativeData.card, cardSettlementDetailEntity: detailEntity, isMultipleMapEnabled: self.isShoppingMapEnabled)
        let headerViewModel = NextSettlementViewModel(configuration, cardDetail: operativeData.cardDetail, baseUrl: baseURLProvider.baseURL, movements: panMovements, paymentMethod: operativeData.currentPaymentMethod, paymentMethodDescription: operativeData.currentPaymentMethodMode, isMultipleMapEnabled: self.isShoppingMapEnabled, ownerPan: settlementMovementsOwnerPan, scaDate: settlementMovementsScaDate, enablePayLater: false)
        return headerViewModel
    }
    
    func setTableViewModels() {
        guard let movementsList = operativeData.settlementMovements else {
            return
        }
        let newSettlementMovements: [NextSettlementMovementViewModel] = movementsList.compactMap { (itemEntity) in
            return NextSettlementMovementViewModel(itemEntity)
        }
        let movementsByDate: [Date: [NextSettlementMovementViewModel]] = newSettlementMovements.reduce([:], groupMovementsByDate)
        let groupedModels = movementsByDate.map({ GroupedMovementsViewModel(date: $0.key, movements: $0.value)}).sorted(by: { $0.date > $1.date })
        self.view?.setGroupedViewModels(groupedModels)
    }
    
    func groupMovementsByDate(_ groupedMovements: [Date: [NextSettlementMovementViewModel]], movement: NextSettlementMovementViewModel) -> [Date: [NextSettlementMovementViewModel]] {
        var groupedMovements = groupedMovements
        guard let operationDate = movement.completeDate else { return groupedMovements }
        guard
            let dateByDay = groupedMovements.keys.first(where: { $0.isSameDay(than: operationDate) }),
            let movementsByDate = groupedMovements[dateByDay]
        else {
            groupedMovements[operationDate.startOfDay()] = [movement]
            return groupedMovements
        }
        groupedMovements[dateByDay] = movementsByDate + [movement]
        return groupedMovements
    }
    
    func didSelectMapMultipleTransactions(_ selectedCard: CardEntity) {
        guard operativeData.isMultipleMapEnabled else { return }
        self.finishingCoordinator.goToMapView(selectedCard, type: CardMapTypeConfiguration.multiple)
    }
}

extension HistoricExtractPresenter: AutomaticScreenActionTrackable {
    var trackerManager: TrackerManager {
        return dependenciesResolver.resolve(for: TrackerManager.self)
    }
    var trackerPage: CardHistoricExtractPage {
        return CardHistoricExtractPage()
    }
}
