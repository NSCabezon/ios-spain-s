//
//  LoanTransactionsViewModel.swift
//  Loans
//
//  Created by Juan Jose Acosta on 10/3/21.
//

import OpenCombine
import CoreFoundationLib
import CoreDomain

enum LoanTransactionSearchState: State {
    case idle
    case initialFilters(TransactionFiltersEntity)
    case configurationLoaded(LoanTransactionSearchConfigRepresentable)
}

final class LoanTransactionSearchViewModel: DataBindable {
    private let dependencies: LoanTransactionSearchDependenciesResolver
    private let stateSubject = CurrentValueSubject<LoanTransactionSearchState, Never>(.idle)
    var state: AnyPublisher<LoanTransactionSearchState, Never>
    private var subscriptions: Set<AnyCancellable> = []
    private var filters = TransactionFiltersEntity()
    @BindingOptional var previousFilters: TransactionFiltersEntity?
    
    var dataBinding: DataBinding {
        return dependencies.resolve()
    }

    init(dependencies: LoanTransactionSearchDependenciesResolver) {
        self.dependencies = dependencies
        state = stateSubject.eraseToAnyPublisher()
    }
    
    func viewDidLoad() {
        if let previusFilters = self.previousFilters {
            self.filters = previusFilters
        }
        subscribeTransactionSearchConfig()
        stateSubject.send(.initialFilters(filters))
        self.trackScreen()
    }
    
    func returnWithFilters(filters: TransactionFiltersEntity) {
        self.coordinator.onFinish = { [weak self] in
            let filterOutsider: LoanFilterOutsider? = self?.dataBinding.get()
            filterOutsider?.send(filters)
        }
        self.coordinator.dismiss()
    }
    
    func close() {
        coordinator.dismiss()
    }
}

private extension LoanTransactionSearchViewModel {
    var coordinator: LoanTransactionSearchCoordinator {
        return dependencies.resolve()
    }
    
    var getTransactionSearchConfigUseCase: GetLoanTransactionSearchConfigUseCase {
        self.dependencies.external.resolve()
    }
}

// MARK: Subscriptions
private extension LoanTransactionSearchViewModel {
    func subscribeTransactionSearchConfig() {
        self.getConfigurationPublished()
            .sink { [unowned self] config in
                self.stateSubject.send(.configurationLoaded(config))
            }.store(in: &subscriptions)
    }
}

// MARK: Publishers
private extension LoanTransactionSearchViewModel {
    func getConfigurationPublished() -> AnyPublisher<LoanTransactionSearchConfigRepresentable, Never> {
        return getTransactionSearchConfigUseCase
            .fetchConfiguration()
            .receive(on: Schedulers.main)
            .eraseToAnyPublisher()
    }
}

extension LoanTransactionSearchViewModel: AutomaticScreenActionTrackable {
    var trackerManager: TrackerManager {
        return dependencies.external.resolve()
    }

    var trackerPage: LoanSearchPage {
        return LoanSearchPage()
    }
}
