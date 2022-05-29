//
//  LoanHomeViewModel.swift
//
//  Santander One App Hub
//  Created by Juan Carlos López Robles on 11/17/21.
//
import UI
import CoreFoundationLib
import Foundation
import OpenCombine
import CoreDomain
import OpenCombineDispatch

enum LoanState: State {
    case idle
    case loansLoaded([LoanRepresentable])
    case selectedLoan(LoanRepresentable?)
    case detailLoaded((loan: LoanRepresentable, detail: LoanDetailRepresentable)?)
    case options([LoanOptionRepresentable])
    case transactionsLoaded([LoanTransactionRepresentable])
    case transactionError(LocalizedError)
    case isHiddenFilters(Bool?)
    case isFullScreenLoading(Bool?)
    case isTransactionLoading(Bool)
    case isPaginationLoading(Bool)
    case transactionSortOrder(by: LoanTransactionsSortOrder)
    case filters(TransactionFiltersRepresentable?)
}

final class LoanHomeViewModel: DataBindable {
    @BindingOptional var defaultLoan: LoanRepresentable?
    private var anySubscriptions: Set<AnyCancellable> = []
    private let filterOutsider = DefaultLoanFilterOutsider()
    private var transactionResult = TransactionResult()
    private var lastTransactionRequest: TransactionRequest?
    private let dependencies: LoanHomeDependenciesResolver
    private let loadDetailSubject = PassthroughSubject<LoanRepresentable, Never>()
    private let loadTransactionsSubject = CurrentValueSubject<TransactionRequest?, Never>(nil)
    private let stateSubject = CurrentValueSubject<LoanState, Never>(.idle)
    var state: AnyPublisher<LoanState, Never>
    private var trackEventSearch = LoanSearchPage()
    
    init(dependencies: LoanHomeDependenciesResolver) {
        self.dependencies = dependencies
        state = stateSubject.eraseToAnyPublisher()
    }
    
    func viewDidLoad() {
        subscribeLoans()
        subscribeDefaultSelectedLoan()
        subscribeLoanOptions()
        subscribeLoanOptionsFromDetail()
        subscribeLoanDetail()
        subscribeLastTransactionRequest()
        subscribeLoanTransactions()
        subscribeFilterOutsider()
        subscribeFilters()
        stateSubject.send(.isHiddenFilters(hideFilterButton))
        stateSubject.send(.transactionSortOrder(by: transactionSortOrder))
        trackScreen()
    }
    
    func didSelectLoan(_ loan: Loan) {
        loadDetail(loan.loan)
        loadTransactions(loan.loan)
        trackEvent(.swipe, parameters: [:])
    }
    
    func loadMoreTransactions() {
        guard transactionResult.next != nil else { return }
        guard let lastRequest = lastTransactionRequest else { return }
        stateSubject.send(.isPaginationLoading(true))
        let loadMoreTransationRequest = TransactionRequest(
            loan: lastRequest.loan,
            next: transactionResult.next,
            filters: lastRequest.filters)
        loadTransactionsSubject.send(loadMoreTransationRequest)
    }
    
    func didSelectShare(_ loan: Loan) {
        coordinator.share(loan, type: .text)
        trackEvent(.copy, parameters: [:])
    }
    
    func didSelectFilter(_ loan: Loan) {
        coordinator.goToFilter(
            with: loan.loan,
            filters: lastTransactionRequest?.filters,
            filterOutsider: filterOutsider)
        trackEvent(.search, parameters: [:])
    }
    
    func didSelectOption(_ viewModel: LoanHomeOption, loan: Loan) {
        switch viewModel.option.type {
        case .repayment:
            coordinator.goToRepayment(with: loan.loan)
        case .changeLoanLinkedAccount:
            coordinator.goToChangeLinkedAccount(with: loan.loan)
        case .detail:
            guard let detail = loan.detail?.detail else { return }
            coordinator.goToLoanDetail(with: loan.loan, detail: detail)
        case .custom(identifier: _):
            coordinator.gotoLoanCustomeOption(with: loan.loan, option: viewModel.option)
        }
    }
    
    func didSelectTransaction(transaction: LoanTransaction) {
        guard let lastRequest = lastTransactionRequest else { return }
        let sortedTransactions = transactionResult.transactions
            .sorted { lhs, rhs in
                switch transactionSortOrder {
                case .mostRecent:
                    return lhs.operationDate ?? Date() > rhs.operationDate ?? Date()
                case .lessRecent:
                    return lhs.operationDate ?? Date() < rhs.operationDate ?? Date()
                }
            }
        coordinator.gotoLoanTransactionDetail(
            transaction: transaction.transaction,
            transactions: sortedTransactions,
            loan: lastRequest.loan
        )
    }
    
    func removeAllFilters() {
        lastTransactionRequest?.filters = nil
        transactionResult = TransactionResult()
        stateSubject.send(.isTransactionLoading(true))
        loadTransactionsSubject.send(lastTransactionRequest)
        trackerManager.trackEvent(screenId: trackEventSearch.page, eventId: LoanSearchPage.Action.removeFilter.rawValue, extraParameters: [:])
    }
    
    func removeFilterFilter(_ filter: ActiveFilters?) {
        transactionResult = TransactionResult()
        stateSubject.send(.isTransactionLoading(true))
        if let removedFilter = filter {
            lastTransactionRequest?.filters?.removeFilter(removedFilter)
        }
        loadTransactionsSubject.send(lastTransactionRequest)
        trackerManager.trackEvent(screenId: trackEventSearch.page, eventId: LoanSearchPage.Action.removeFilter.rawValue, extraParameters: [:])
    }
    
    @objc func didSelectGoBack() {
        coordinator.dismiss()
    }
    
    @objc func didSelectOpenMenu() {
        coordinator.openMenu()
    }
    
    @objc func didSelectGlobalSearch() {
        coordinator.gotoGlobalSearch()
    }
    
    var dataBinding: DataBinding {
        return dependencies.resolve()
    }
}

private extension LoanHomeViewModel {
    var getLoansUsecase: GetLoansUsecase {
        return dependencies.resolve()
    }
    
    var getLoanOptionsUsecase: GetLoanOptionsUsecase {
        return dependencies.external.resolve()
    }
    
    var getLoanDetailUsecase: GetLoanDetailUsecase {
        return dependencies.external.resolve()
    }
    
    var getLoanTransactionUsecase: GetLoanTransactionsUsecase {
        return dependencies.resolve()
    }
    
    var coordinator: LoanHomeCoordinator {
        return dependencies.resolve()
    }
    
    var loanModifier: LoansModifierProtocol? {
        return dependencies.external.resolve()
    }
    
    var transactionSortOrder: LoanTransactionsSortOrder {
        return loanModifier?.transactionSortOrder ?? . mostRecent
    }
    
    var hideFilterButton: Bool? {
        return loanModifier?.hideFilterButton
    }

    func loadDetail(_ loan: LoanRepresentable) {
        stateSubject.send(.isFullScreenLoading(loanModifier?.waitForLoanDetail))
        loadDetailSubject.send(loan)
    }
    
    func loadTransactions(_ loan: LoanRepresentable) {
        transactionResult = TransactionResult()
        stateSubject.send(.isTransactionLoading(true))
        let request = TransactionRequest(loan: loan)
        loadTransactionsSubject.send(request)
    }
}

// MARK: Subscriptions
private extension LoanHomeViewModel {
    func subscribeLoans() {
        loansPublisher()
            .sink { [unowned self] loans  in
                self.stateSubject.send(.loansLoaded(loans))
                self.stateSubject.send(.selectedLoan(self.defaultLoan ?? loans.first))
            }.store(in: &anySubscriptions)
    }
    
    func subscribeDefaultSelectedLoan() {
        let sharedLoan = state
            .case(LoanState.selectedLoan)
            .compactMap({ $0 })
            .share()
        
        sharedLoan
            .sink {[unowned self] loan in
                self.loadDetail(loan)
            }.store(in: &anySubscriptions)
        
        sharedLoan
            .sink {[unowned self] loan in
                self.loadTransactions(loan)
            }.store(in: &anySubscriptions)
    }
    
    func subscribeLoanOptions() {
        loanOptionPublisher()
            .sink {[unowned self] options in
                self.stateSubject.send(.options(options))
            }.store(in: &anySubscriptions)
    }
    
    func subscribeLoanOptionsFromDetail() {
        state
            .case(LoanState.detailLoaded)
            .compactMap({ $0?.detail })
            .flatMap {[unowned self] detail in
                self.loanOptionPublisher(loanDetail: detail)
            }.filter { options in
                !options.isEmpty
            }.sink { [unowned self] options in
                self.stateSubject.send(.options(options))
            }.store(in: &anySubscriptions)
    }
    
    func subscribeLoanDetail() {
        loanDetailPublisher()
            .sink { result in
                self.stateSubject.send(.detailLoaded(result))
                self.stateSubject.send(.isFullScreenLoading(false))
            }.store(in: &anySubscriptions)
    }
    
    func subscribeLoanTransactions() {
        loanTransactionPublisher()
            .sink { [unowned self] result in
                do {
                    self.transactionResult.transactions.append(contentsOf: try result.get().transactions)
                    self.transactionResult.next = try result.get().next
                    self.stateSubject.send(.transactionsLoaded(self.transactionResult.transactions))
                } catch let error as LocalizedError {
                    self.stateSubject.send(.transactionError(error))
                }
                self.stateSubject.send(.isTransactionLoading(false))
                self.stateSubject.send(.isPaginationLoading(false))
            }.store(in: &anySubscriptions)
    }
    
    func subscribeFilterOutsider() {
        filterOutsider.publisher
            .sink { [unowned self] filters in
                guard let lastRequest = lastTransactionRequest else { return }
                let transactionRequestWithFilters = TransactionRequest(
                    loan: lastRequest.loan,
                    next: nil,
                    filters: filters
                )
                self.transactionResult = TransactionResult()
                self.stateSubject.send(.isTransactionLoading(true))
                self.loadTransactionsSubject.send(transactionRequestWithFilters)
            }.store(in: &anySubscriptions)
    }
    
    func subscribeFilters() {
        state.case(LoanState.transactionsLoaded)
            .sink { [unowned self] _ in
                self.stateSubject.send(.filters(lastTransactionRequest?.filters))
            }.store(in: &anySubscriptions)
        
        state.case(LoanState.transactionError)
            .sink { [unowned self] _ in
                self.stateSubject.send(.filters(lastTransactionRequest?.filters))
            }.store(in: &anySubscriptions)
    }
    
    func subscribeLastTransactionRequest() {
        loadTransactionsSubject
            .sink { [unowned self] lastRequest in
                self.lastTransactionRequest = lastRequest
            }.store(in: &anySubscriptions)
    }
}

// MARK: Publishers
private extension LoanHomeViewModel {
    func loansPublisher() -> AnyPublisher<[LoanRepresentable], Never> {
        return getLoansUsecase
            .fechLoans()
            .receive(on: Schedulers.main)
            .eraseToAnyPublisher()
    }
    
    func loanOptionPublisher() -> AnyPublisher<[LoanOptionRepresentable], Never> {
        return getLoanOptionsUsecase
            .fetchOptionsPublisher()
            .receive(on: Schedulers.main)
            .eraseToAnyPublisher()
    }
    
    func loanOptionPublisher(loanDetail: LoanDetailRepresentable) -> AnyPublisher<[LoanOptionRepresentable], Never> {
        return getLoanOptionsUsecase
            .fetchOptionsPublisher(loanDetail: loanDetail)
            .eraseToAnyPublisher()
    }
    
    func loanDetailPublisher() -> AnyPublisher<(LoanRepresentable, LoanDetailRepresentable)?, Never> {
        return loadDetailSubject
            .flatMap { [unowned self] loan in
                self.getLoanDetailUsecase
                    .fechDetailPublisher(loan: loan)
                    .map {(loan: loan, detail: $0)}
                    .replaceError(with: nil)
            }.receive(on: Schedulers.main)
            .eraseToAnyPublisher()
    }
    
    func loanTransactionPublisher() -> AnyPublisher<Result<LoanResultPageRepresentable, Error>, Never> {
        return loadTransactionsSubject
            .compactMap({ $0 })
            .flatMap {[unowned self] request in
                self.getLoanTransactionUsecase
                    .loadTransactionsPublisher(loan: request.loan, page: request.next, filters: request.filters)
                    .map { Result.success($0) }
                    .catch { error in
                        Just(Result.failure(error))
                    }
            }
            .receive(on: Schedulers.main)
            .eraseToAnyPublisher()
    }
}

// MARK: Analytics
extension LoanHomeViewModel: AutomaticScreenActionTrackable {
    var trackerManager: TrackerManager {
        dependencies.external.resolve()
    }

    var trackerPage: LoanPage {
        LoanPage()
    }
}

private extension LoanHomeViewModel {
    struct TransactionResult: LoanResultPageRepresentable {
        var transactions: [LoanTransactionRepresentable] = []
        var next: PaginationRepresentable?
    }

    struct TransactionRequest {
        var loan: LoanRepresentable
        var next: PaginationRepresentable?
        var filters: LoanFilterRepresentable?
    }
}
