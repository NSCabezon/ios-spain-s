//
//  FundTransactionsViewModel.swift
//  Funds
//
//  Created by Ernesto Fernandez Calles on 28/3/22.
//

import UI
import CoreFoundationLib
import Foundation
import OpenCombine
import CoreDomain

enum FundTransactionsState: State {
    case idle
    case selectedFund(FundRepresentable?)
    case isTransactionLoading(Bool)
    case isPaginationLoading(Bool)
    case isTransactionDetailLoading(Bool)
    case movementsLoaded((fund: FundRepresentable, movementList: [FundMovementRepresentable]))
    case movementsError(LocalizedError)
    case errorReceived
    case movementDetailLoaded((fund: FundRepresentable, movement: FundMovementRepresentable, movementDetails: FundMovementDetailRepresentable?)?)
}

final class FundTransactionsViewModel: DataBindable {

    @BindingOptional var fund: FundRepresentable?
    @BindingOptional var fundMovements: FundMovementListRepresentable?
    private var anySubscriptions: Set<AnyCancellable> = []
    private let dependencies: FundTransactionsDependenciesResolver
    private let fundSelectedSubject = PassthroughSubject<FundRepresentable, Never>()
    private let loadTransactionsSubject = CurrentValueSubject<TransactionRequest?, Never>(nil)
    private let fundMovementDetailsSubject = PassthroughSubject<(FundMovementRepresentable, FundRepresentable), Never>()
    private let stateSubject = CurrentValueSubject<FundTransactionsState, Never>(.idle)
    private let filterOutsider = DefaultFundsFilterOutsider()
    private var transactionResult = TransactionResult()
    private var lastTransactionRequest: TransactionRequest?
    var state: AnyPublisher<FundTransactionsState, Never>

    init(dependencies: FundTransactionsDependenciesResolver) {
        self.dependencies = dependencies
        self.state = self.stateSubject.eraseToAnyPublisher()
    }

    func viewDidLoad() {
        self.trackScreen()
        subscribeFundTransactions()
        subscribeLastTransactionRequest()
        subscribeFilterOutsider()
        subscribeMovementDetails()
        guard let fund = self.fund else {
            return
        }
        loadTransactions(fund)
    }

    @objc func didSelectGoBack() {
        self.trackEvent(.back)
        self.coordinator.dismiss()
    }

    @objc func didSelectOpenMenu() {
        self.trackEvent(.menu)
        self.coordinator.openMenu()
    }

    func goToFilter() {
        guard let fund = self.fund else {
            return
        }
        self.trackEvent(.filter)
        self.coordinator.goToFilter(with: fund, filters: self.lastTransactionRequest?.filters, filterOutsider: self.filterOutsider)
    }

    func didLoadMoreMovements() {
        guard transactionResult.next != nil else { return }
        guard let lastRequest = lastTransactionRequest else { return }
        stateSubject.send(.isPaginationLoading(true))
        let loadMoreTransationRequest = TransactionRequest(
            fund: lastRequest.fund,
            next: transactionResult.next,
            filters: lastRequest.filters)
        loadTransactionsSubject.send(loadMoreTransationRequest)
    }

    var dataBinding: DataBinding {
        return self.dependencies.resolve()
    }

    var filters: FundsFilterRepresentable? {
        self.lastTransactionRequest?.filters
    }

    func updateFilters(with newFilters: FundsFilterRepresentable?) {
        self.lastTransactionRequest = nil
        transactionResult = TransactionResult()
        guard let fund = self.fund else { return }
        self.stateSubject.send(.isTransactionLoading(true))
        let request = TransactionRequest(fund: fund, next: nil, filters: newFilters)
        loadTransactionsSubject.send(request)
    }

    func didSelectMovementDetail(for movement: FundMovementRepresentable, in fund: FundRepresentable) {
        let movementsModifier: FundsHomeMovementsModifier? = self.dependencies.external.common.resolve()
        if movementsModifier?.isMoreDetailInfoEnabled ?? false {
            self.loadMovementDetails(for: movement, in: fund)
        } else {
            self.stateSubject.send(.movementDetailLoaded((fund, movement, nil)))
        }
    }
}

private extension FundTransactionsViewModel {

    var coordinator: FundTransactionsCoordinator {
        return self.dependencies.resolve()
    }

    var getFundMovementsUsecase: GetFundMovementsUseCase {
        return dependencies.resolve()
    }

    func loadTransactions(_ fund: FundRepresentable) {
        self.stateSubject.send(FundTransactionsState.movementsLoaded((fund: fund, movementList: [])))
        transactionResult = TransactionResult()
        stateSubject.send(.isTransactionLoading(true))
        let request = TransactionRequest(fund: fund)
        loadTransactionsSubject.send(request)
    }

    func loadMovementDetails(for movement: FundMovementRepresentable, in fund: FundRepresentable) {
        self.stateSubject.send(.isTransactionDetailLoading(true))
        self.fundMovementDetailsSubject.send((movement, fund))
        self.trackEvent(.units)
    }
}

// MARK: Subscriptions
private extension FundTransactionsViewModel {

    func subscribeMovementDetails() {
        fundMovementDetailsPublisher()
            .sink { [unowned self] result in
                self.stateSubject.send(.movementDetailLoaded(result))
                self.stateSubject.send(.isTransactionDetailLoading(false))
            }.store(in: &anySubscriptions)
    }

    func subscribeFilterOutsider() {
        filterOutsider.publisher
            .sink { [unowned self] filters in
                guard let lastRequest = lastTransactionRequest else { return }
                self.lastTransactionRequest = TransactionRequest(fund: lastRequest.fund, next: nil, filters: filters)
                self.transactionResult = TransactionResult()
                self.stateSubject.send(.isTransactionLoading(true))
                loadTransactionsSubject.send(lastTransactionRequest)
            }.store(in: &anySubscriptions)
    }

    func subscribeLastTransactionRequest() {
        loadTransactionsSubject
            .sink { [unowned self] lastRequest in
                self.lastTransactionRequest = lastRequest
            }.store(in: &anySubscriptions)
    }

    func subscribeFundTransactions() {
        fundTransactionPublisher()
            .sink { [unowned self] result in
                self.stateSubject.send(.isTransactionLoading(false))
                self.stateSubject.send(.isPaginationLoading(false))
                do {
                    guard let fund = lastTransactionRequest?.fund else {
                        return
                    }
                    self.transactionResult.transactions.append(contentsOf: try result.get().transactions)
                    self.transactionResult.next = try result.get().next
                    self.stateSubject.send(FundTransactionsState.movementsLoaded((fund: fund, movementList: try result.get().transactions)))
                } catch let error as LocalizedError {
                    self.trackEvent(.error)
                    self.stateSubject.send(.movementsError(error))
                }

            }.store(in: &anySubscriptions)
    }
}

// MARK: Publishers
private extension FundTransactionsViewModel {

    func fundTransactionPublisher() -> AnyPublisher<Result<FundMovementListRepresentable, Error>, Never> {
        return loadTransactionsSubject
            .compactMap({ $0 })
            .flatMap {[unowned self] request in
                self.getFundMovementsUsecase
                    .fechMovementsPublisher(fund: request.fund, pagination: request.next, filters: request.filters)
                    .map { Result.success($0) }
                    .catch { error in
                        Just(Result.failure(error))
                    }
            }
            .receive(on: Schedulers.main)
            .eraseToAnyPublisher()
    }

    func fundMovementDetailsPublisher() -> AnyPublisher<(FundRepresentable, FundMovementRepresentable, FundMovementDetailRepresentable?)?, Never> {
        return fundMovementDetailsSubject
            .flatMap { [unowned self] (movement, fund) in
                self.getFundMovementsUsecase
                    .fechMovementDetailsPublisher(fund: fund, movement: movement)
                    .map {(fund, movement, $0)}
                    .catch({ (_) -> Just<(FundRepresentable, FundMovementRepresentable, FundMovementDetailRepresentable?)?> in
                        self.trackEvent(.error)
                        return Just(nil)
                    })
            }.receive(on: Schedulers.main)
            .eraseToAnyPublisher()
    }
}

private extension FundTransactionsViewModel {

    struct TransactionResult: FundMovementListRepresentable {
        var transactions: [FundMovementRepresentable] = []
        var next: PaginationRepresentable?
    }

    struct TransactionRequest {
        var fund: FundRepresentable
        var next: PaginationRepresentable?
        var filters: FundsFilterRepresentable?
    }
}

extension FundTransactionsViewModel: AutomaticScreenActionTrackable {
    var trackerManager: TrackerManager {
        return dependencies.external.resolve()
    }

    var trackerPage: FundTransactionsPage {
        return FundTransactionsPage()
    }
}
