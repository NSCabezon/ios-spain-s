//
//  NextSettlementMovementsPresenter.swift
//  Cards
//
//  Created by David Gálvez Alonso on 14/10/2020.
//

import CoreFoundationLib

protocol NextSettlementMovementsPresenterProtocol: AnyObject, MenuTextWrapperProtocol {
    var view: NextSettlementMovementsViewProtocol? { get set }
    func viewDidLoad()
    func didSelectDismiss()
    func didTapInCardSegmented(_ index: Int)
    func didTapPickerCard(_ index: Int)
}

final class NextSettlementMovementsPresenter {
    weak var view: NextSettlementMovementsViewProtocol?
    var dependenciesResolver: DependenciesResolver
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
}

extension NextSettlementMovementsPresenter: NextSettlementMovementsPresenterProtocol {
    func viewDidLoad() {
        self.trackScreen()
        self.buildCardActions()
        self.setHeaderViewModel()
        self.setTableViewModels()
        self.checkShowViewsByNumberOfCards()
    }
    
    func didSelectDismiss() {
        self.nextSettlementMovementsCoordinator.dismiss()
    }
    
    func didTapInCardSegmented(_ index: Int) {
        guard let nextSettlementViewModel = configuration.nextSettlementViewModel else {
            return
        }
        let selectedPan = index == 0 ? nextSettlementViewModel.getOwnerPanOrOriginalPan : nextSettlementViewModel.getFirstAssociatedPan
        nextSettlementViewModel.setCurrentPanSelected(selectedPan)
        self.setTableViewModels()
        self.buildCardActions()
        self.view?.setTotalAmount(nextSettlementViewModel.getMovementWithPan?.movements ?? [])
        self.view?.scrollTableViewToTop()
    }
    
    func didTapPickerCard(_ index: Int) {
        let selectedPan = configuration.nextSettlementViewModel?.ownerCards?[index].pan
        configuration.nextSettlementViewModel?.setCurrentPanSelected(selectedPan ?? "")
        guard let nextSettlementViewModel = configuration.nextSettlementViewModel else {
            return
        }
        self.setTableViewModels()
        self.buildCardActions()
        self.view?.setTotalAmount(nextSettlementViewModel.getMovementWithPan?.movements ?? [])
        self.view?.scrollTableViewToTop()
    }
}

private extension NextSettlementMovementsPresenter {
    var nextSettlementMovementsCoordinator: NextSettlementMovementsCoordinator {
        return dependenciesResolver.resolve(for: NextSettlementMovementsCoordinator.self)
    }
    
    var configuration: NextSettlementMovementsConfiguration {
        return self.dependenciesResolver.resolve(for: NextSettlementMovementsConfiguration.self)
    }
    
    var homeCoordinatorDelegate: CardsHomeModuleCoordinatorDelegate? {
        return self.dependenciesResolver.resolve(for: CardsHomeModuleCoordinatorDelegate.self)
    }
    
    func buildCardActions() {
        self.setCardActions { [weak self] action, entity in
            self?.didSelectAction(action, cardEntity: entity)
            guard
                let trackName = action.trackName,
                let actionType = CardSettlementListPage.ActionType(rawValue: trackName)
            else { return }
            self?.trackEvent(actionType, parameters: [:])
        }
    }
        
    func setCardActions(_ action: ((NextSettlementActionType, CardEntity) -> Void)?) {
        guard let nextSettlementViewModel = self.configuration.nextSettlementViewModel,
            let cardSelected = nextSettlementViewModel.getCurrentCardSelected(nextSettlementViewModel.getCurrentPanSelected)?.entity else {
                return
        }
        let isEnabledPostponeReceipt = nextSettlementViewModel.getEnabledPostponeReceipt(cardSelected)
        var actions: [NextSettlementActionViewModel] = []
        actions.append(NextSettlementActionViewModel(type: .postponeReceipt,
                                                     entity: cardSelected,
                                                     isDisabled: !isEnabledPostponeReceipt || !cardSelected.isOwnerSuperSpeed,
                                                     action: action,
                                                     isRemarkable: nextSettlementViewModel.isReceiptRemarkable))
        actions.append(NextSettlementActionViewModel(type: .changePaymentMethod,
                                                     entity: cardSelected,
                                                     isDisabled: !cardSelected.isOwnerSuperSpeed,
                                                     action: action))
        actions.append(NextSettlementActionViewModel(type: .historicExtractPDF,
                                                     entity: cardSelected,
                                                     action: action))
        actions.append(NextSettlementActionViewModel(type: .shoppingMap,
                                                     entity: cardSelected,
                                                     isDisabled: !nextSettlementViewModel.getMultipleMapEnabled,
                                                     action: action))
        self.view?.setActions(actions)
    }
    
    func didSelectAction(_ type: NextSettlementActionType, cardEntity: CardEntity) {
        switch type {
        case .postponeReceipt, .changePaymentMethod, .historicExtractPDF:
            self.homeCoordinatorDelegate?.didSelectSettlementAction(type, entity: cardEntity)
        case .shoppingMap:
            self.didSelectMapSettlement(cardEntity)
        }
    }
           
    func didSelectMapMultipleTransactions(_ selectedCard: CardEntity) {
        guard
            let nextSettlementViewModel = configuration.nextSettlementViewModel,
            nextSettlementViewModel.getMultipleMapEnabled else { return }
        self.nextSettlementMovementsCoordinator.goToMapView(selectedCard, type: CardMapTypeConfiguration.multiple)
    }
    
    func didSelectMapSettlement(_ selectedCard: CardEntity) {
        guard
            let nextSettlementViewModel = configuration.nextSettlementViewModel,
            let startDate = nextSettlementViewModel.settlementDetailEntity.startDate,
            let endDate = nextSettlementViewModel.settlementDetailEntity.endDate
            else {
                self.didSelectMapMultipleTransactions(selectedCard)
                return
        }
        let configurationMapType = CardMapTypeConfiguration.date(startDate: startDate, endDate: endDate)
        self.nextSettlementMovementsCoordinator.goToMapView(selectedCard, type: configurationMapType)
    }
    
    func setHeaderViewModel() {
        guard let nextSettlementViewModel = configuration.nextSettlementViewModel else {
            return
        }
        self.view?.setHeaderViewModel(nextSettlementViewModel)
    }
    
    func setTableViewModels() {
        guard let nextSettlementViewModel = configuration.nextSettlementViewModel?.getMovementWithPan?.movements else {
            return
        }
        let movementsByDate: [Date: [NextSettlementMovementViewModel]] = nextSettlementViewModel.reduce([:], groupMovementsByDate)
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
    
    func checkShowViewsByNumberOfCards() {
        guard let nextSettlementViewModel = configuration.nextSettlementViewModel else {
            return
        }
        switch nextSettlementViewModel.getNumberOfCards() {
        case .two:
            self.view?.setCardSegmentedView(nextSettlementViewModel)
            self.view?.setTotalAmount(nextSettlementViewModel.getMovementWithPan?.movements ?? [])
        case .more:
            self.view?.setCardSelector(nextSettlementViewModel)
            self.view?.setTotalAmount(nextSettlementViewModel.getMovementWithPan?.movements ?? [])
        default:
            break
        }
    }
}

extension NextSettlementMovementsPresenter: AutomaticScreenActionTrackable {
    var trackerPage: CardSettlementListPage {
        return CardSettlementListPage()
    }
    
    var trackerManager: TrackerManager {
        dependenciesResolver.resolve(for: TrackerManager.self)
    }
}
