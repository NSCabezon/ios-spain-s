//
//  PendingTransactionDetailPresenter.swift
//  Cards
//
//  Created by Juan Carlos López Robles on 9/16/20.
//

import Foundation
import CoreFoundationLib

protocol PendingTransactionDetailPresenterProtocol: MenuTextWrapperProtocol {
    var view: PendingTransactionDetailView? { get set }
    func didSelectViewModel(_ viewModel: PendingTransactionDetailViewModel)
    func viewDidLoad()
    func didSelectDismiss()
    func didSelectMenu()
}

final class PendingTransactionDetailPresenter {
    weak var view: PendingTransactionDetailView?
    internal let dependenciesResolver: DependenciesResolver
    private var configuration: PendingTransactionDetailConfiguration {
        return self.dependenciesResolver.resolve(for: PendingTransactionDetailConfiguration.self)
    }
    private var coordinator: PendingTransactionDetailCoordinatorProtocol {
        self.dependenciesResolver.resolve(for: PendingTransactionDetailCoordinatorProtocol.self)
    }
    private var coordinatorDelegate: PendingTransactionDetailCoordinatorDelegate {
        return self.dependenciesResolver.resolve(for: PendingTransactionDetailCoordinatorDelegate.self)
    }
    private var timeManater: TimeManager {
        return self.dependenciesResolver.resolve(for: TimeManager.self)
    }
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
}

extension PendingTransactionDetailPresenter: PendingTransactionDetailPresenterProtocol {
    func viewDidLoad() {
        self.setTransactions()
        self.trackScreen()
    }
    
    func didSelectDismiss() {
        self.coordinator.didSelectDismiss()
    }
    
    func didSelectMenu() {
        self.coordinatorDelegate.didSelectMenu()
    }
    
    func setTransactions() {
        let selectedTransaction = self.configuration.selectedTransaction
        let transactions = self.configuration.transactions
        let cardEntity = self.configuration.cardEntity
        let selectedViewModel = PendingTransactionDetailViewModel(selectedTransaction, cardEntity: cardEntity, timeManager: timeManater)
        let viewModels = transactions.map { PendingTransactionDetailViewModel($0, cardEntity: cardEntity, timeManager: timeManater) }
        self.setActions(viewModel: selectedViewModel)
        self.view?.showTransaction(selectedViewModel, viewModels: viewModels)
    }
    
    func didSelectViewModel(_ viewModel: PendingTransactionDetailViewModel) {
        self.setActions(viewModel: viewModel)
    }
    
    func setActions(viewModel: PendingTransactionDetailViewModel) {
        let builder = PendingTransactionDetailActionBuilder(entity: configuration.cardEntity, dependenciesResolver: dependenciesResolver)
        builder.addEnable(self.didSelectAction)
        builder.addOn(self.didSelectAction)
        builder.addOff(self.didSelectAction)
        builder.addDirectMoney(self.didSelectAction)
        builder.addShare(viewModel: viewModel, self.didSelectAction)
        self.view?.showActions(builder.build())
    }
    
    func didSelectAction(_ action: OldCardActionType, _ entity: CardEntity) {
        self.coordinatorDelegate.didSelectAction(action, entity)
        switch action {
        case .offCard:
            self.trackEvent(.offCard, parameters: [:])
        case .instantCash:
            self.trackEvent(.instantCash, parameters: [:])
        case .share:
            self.trackEvent(.share, parameters: [:])
        default:
            break
        }
    }
}

extension PendingTransactionDetailPresenter: AutomaticScreenActionTrackable {
    var trackerPage: CardPendingTransactionPage {
        return CardPendingTransactionPage()
    }
    var trackerManager: TrackerManager {
        return self.dependenciesResolver.resolve(for: TrackerManager.self)
    }
}
