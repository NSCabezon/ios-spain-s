//
//  FundsTransactionsFilterViewModel.swift
//  Funds
//

import OpenCombine
import CoreFoundationLib
import CoreDomain

enum FundsTransactionsFilterState: State {
    case idle
    case initialFilters(TransactionFiltersEntity)
    case filtersChanged(TransactionFiltersEntity)
}

final class FundsTransactionsFilterViewModel: DataBindable {
    private let dependencies: FundsTransactionsFilterDependenciesResolver
    private let stateSubject = CurrentValueSubject<FundsTransactionsFilterState, Never>(.idle)
    var state: AnyPublisher<FundsTransactionsFilterState, Never>
    private var subscriptions: Set<AnyCancellable> = []
    private var filters = TransactionFiltersEntity()
    @BindingOptional var previousFilters: TransactionFiltersEntity?
    
    var dataBinding: DataBinding {
        return dependencies.resolve()
    }

    var isAnyFilterActive: Bool {
        guard let dateFilter = self.filters.getDateRange() else { return false }
        return !dateFilter.fromDate.isNil && !dateFilter.toDate.isNil
    }

    var minDateFilter: Date {
        self.filterModifier?.minFilterDate ?? Date().addMonth(months: -25)
    }

    init(dependencies: FundsTransactionsFilterDependenciesResolver) {
        self.dependencies = dependencies
        state = stateSubject.eraseToAnyPublisher()
    }
    
    func viewDidLoad() {
        if let previusFilters = self.previousFilters {
            self.filters = previusFilters
        } else {
            self.filters.addDateFilter(nil, toDate: Date())
        }
        stateSubject.send(.initialFilters(filters))
        self.trackScreen()
    }
    
    func returnWithFilters() {
        self.trackEvent(.apply)
        self.coordinator.onFinish = { [weak self] in
            let filterOutsider: FundsFilterOutsider? = self?.dataBinding.get()
            filterOutsider?.send(self?.filters ?? TransactionFiltersEntity())
        }
        self.coordinator.dismiss()
    }

    func updateDateRangeFilters(fromDate: Date? = nil, toDate: Date? = nil) {
        let fromDate = fromDate ?? self.filters.getDateRange()?.fromDate
        let toDate = toDate ?? self.filters.getDateRange()?.toDate
        filters = TransactionFiltersEntity()
        self.filters.addDateFilter(fromDate, toDate: toDate)
        self.stateSubject.send(FundsTransactionsFilterState.filtersChanged(self.filters))
    }

    func close() {
        coordinator.dismiss()
    }
}

private extension FundsTransactionsFilterViewModel {
    var coordinator: FundsTransactionsFilterCoordinator {
        return dependencies.resolve()
    }

    var filterModifier: FundsTransactionsFilterModifier? {
        dependencies.external.resolve()
    }
}

// MARK: Subscriptions
private extension FundsTransactionsFilterViewModel {}

// MARK: Publishers
private extension FundsTransactionsFilterViewModel {}

extension FundsTransactionsFilterViewModel: AutomaticScreenActionTrackable {
    var trackerManager: TrackerManager {
        return dependencies.external.resolve()
    }

    var trackerPage: FundTransactionsFilterPage {
        return FundTransactionsFilterPage()
    }
}
