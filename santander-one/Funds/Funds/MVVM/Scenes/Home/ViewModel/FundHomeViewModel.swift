//
//  FundHomeViewModel.swift
//  Funds
//

import UI
import CoreFoundationLib
import Foundation
import OpenCombine
import CoreDomain
import OpenCombineDispatch

enum FundState: State {
    case idle
    case fundsLoaded([FundRepresentable])
    case selectedFund(FundRepresentable?)
    case options([FundOptionRepresentable])
    case detailLoaded((fund: FundRepresentable, detail: FundDetailRepresentable)?)
    case movementsLoaded((fund: FundRepresentable, movementList: FundMovementListRepresentable)?)
    case movementsError(LocalizedError)
    case isDetailLoading(_ isLoading: Bool)
    case isMovementDetailLoading(_ isLoading: Bool)
    case isMovementsLoading(_ isLoading: Bool)
    case movementDetailLoaded((fund: FundRepresentable, movement: FundMovementRepresentable, movementDetails: FundMovementDetailRepresentable?)?)
}

final class FundHomeViewModel: DataBindable {
    @BindingOptional var defaultFund: FundRepresentable?
    private var anySubscriptions: Set<AnyCancellable> = []
    private let dependencies: FundsHomeDependenciesResolver
    private let fundDetailSubject = PassthroughSubject<FundRepresentable, Never>()
    private let fundMovementsSubject = PassthroughSubject<FundRepresentable, Never>()
    private let fundMovementDetailsSubject = PassthroughSubject<(FundMovementRepresentable, FundRepresentable), Never>()
    private let stateSubject = CurrentValueSubject<FundState, Never>(.idle)
    var state: AnyPublisher<FundState, Never>

    init(dependencies: FundsHomeDependenciesResolver) {
        self.dependencies = dependencies
        self.state = self.stateSubject.eraseToAnyPublisher()
    }
    
    func viewDidLoad() {
        self.subscribeFunds()
        self.subscribeDefaultSelectedFund()
        self.subscribeFundOptions()
        self.subscribeFundDetail()
        self.subscribeMovements()
        self.subscribeMovementDetails()
        trackScreen()
    }
    
    func needsToLoadDetail(_ fund: Fund) {
        self.loadDetail(fund.fundRepresentable)
    }

    func needsToLoadMovements(_ fund: Fund) {
        self.loadMovements(fund.fundRepresentable)
        if let alias = fund.alias {
            let params: [String: String] = ["item_id": alias,
                                            "product_category": "investment",
                                            "content_type": "fund"]
            trackEvent(.select, parameters: params)
        }

    }

    func didSelectShare(_ shareable: Shareable, trackAction: FundPage.Action? = nil) {
        coordinator.share(shareable, type: .text)
        if let action = trackAction {
            trackEvent(action)
        }
    }

    func didSelectOption(_ viewModel: FundHomeOption, fund: Fund) {
        switch viewModel.option.type {
        case .custom(identifier: _):
            self.coordinator.gotoFundCustomeOption(with: fund.fundRepresentable, option: viewModel.option)
        }
    }

    func didSelectMovementDetail(for movement: FundMovementRepresentable, in fund: FundRepresentable) {
        let movementsModifier: FundsHomeMovementsModifier? = self.dependencies.external.common.resolve()
        if movementsModifier?.isMoreDetailInfoEnabled ?? false {
            self.loadMovementDetails(for: movement, in: fund)
        } else {
            self.stateSubject.send(.movementDetailLoaded((fund, movement, nil)))
        }
    }

    @objc func didSelectGoBack() {
        self.coordinator.dismiss()
        trackEvent(.back)
    }
    
    @objc func didSelectOpenMenu() {
        self.coordinator.openMenu()
        trackEvent(.menu)
    }
    
    @objc func didSelectGlobalSearch() {
        self.coordinator.gotoGlobalSearch()
    }

    func didSelectProfitabilityTooltip() {
        self.coordinator.showProfitabilityTooltip()
        trackEvent(.profitabilityTooltip)
    }

    func didSelectTransactions(_ fundMovements: FundMovements) {
        self.coordinator.gotoTransactions(with: fundMovements.fund)
    }
    
    var dataBinding: DataBinding {
        return self.dependencies.resolve()
    }
}

private extension FundHomeViewModel {
    var getFundsUsecase: GetFundsUseCase {
        return self.dependencies.resolve()
    }

    var getFundOptionsUsecase: GetFundOptionsUsecase {
        return self.dependencies.external.resolve()
    }

    var coordinator: FundsHomeCoordinator {
        return self.dependencies.resolve()
    }

    var getFundMovementsUsecase: GetFundMovementsUseCase {
        return dependencies.resolve()
    }

    func loadDetail(_ fund: FundRepresentable) {
        self.stateSubject.send(.isDetailLoading(true))
        fundDetailSubject.send(fund)
    }

    func loadMovements(_ fund: FundRepresentable) {
        stateSubject.send(.isMovementsLoading(true))
        fundMovementsSubject.send(fund)
    }

    func loadMovementDetails(for movement: FundMovementRepresentable, in fund: FundRepresentable) {
        self.stateSubject.send(.isMovementDetailLoading(true))
        self.fundMovementDetailsSubject.send((movement, fund))
    }
}

// MARK: Subscriptions
private extension FundHomeViewModel {
    func subscribeFunds() {
        self.fundsPublisher()
            .sink { [unowned self] funds in
                self.stateSubject.send(.fundsLoaded(funds))
                self.stateSubject.send(.selectedFund(self.defaultFund ?? funds.first))
            }.store(in: &self.anySubscriptions)
    }
    
    func subscribeDefaultSelectedFund() {
        _ = self.state
            .case(FundState.selectedFund)
            .compactMap({ $0 })
            .share()
    }

    func subscribeFundOptions() {
        self.fundOptionPublisher()
            .sink {[unowned self] options in
                self.stateSubject.send(.options(options))
            }.store(in: &self.anySubscriptions)
    }

    func subscribeFundDetail() {
        fundDetailPublisher()
            .sink { result in
                self.stateSubject.send(.detailLoaded(result))
                self.stateSubject.send(.isDetailLoading(false))
            }.store(in: &anySubscriptions)
    }

    func subscribeMovements() {
        fundMovementsPublisher()
            .sink { result in
                do {
                    let movementsLoaded = try result.get()
                    self.stateSubject.send(.movementsLoaded(movementsLoaded))
                } catch let error as LocalizedError {
                    self.trackEvent(.error)
                    self.stateSubject.send(.movementsError(error))
                }
                self.stateSubject.send(.isMovementsLoading(false))
            }.store(in: &anySubscriptions)
    }

    func subscribeMovementDetails() {
        fundMovementDetailsPublisher()
            .sink { [unowned self] result in
                self.stateSubject.send(.movementDetailLoaded(result))
                self.stateSubject.send(.isMovementDetailLoading(false))
            }.store(in: &anySubscriptions)
    }

    var getFundDetailUsecase: GetFundDetailUsecase {
        return dependencies.external.resolve()
    }
}

// MARK: Publishers
private extension FundHomeViewModel {
    func fundsPublisher() -> AnyPublisher<[FundRepresentable], Never> {
        return self.getFundsUsecase
            .fechFunds()
            .receive(on: Schedulers.main)
            .eraseToAnyPublisher()
    }

    func fundOptionPublisher() -> AnyPublisher<[FundOptionRepresentable], Never> {
        return self.getFundOptionsUsecase
            .fetchOptionsPublisher()
            .receive(on: Schedulers.main)
            .eraseToAnyPublisher()
    }

    func fundDetailPublisher() -> AnyPublisher<(FundRepresentable, FundDetailRepresentable)?, Never> {
        return fundDetailSubject
            .flatMap { [unowned self] fund in
                self.getFundDetailUsecase
                    .fechDetailPublisher(fund: fund)
                    .map {(fund: fund, detail: $0)}
                    .catch({ (_) -> Just<(FundRepresentable, FundDetailRepresentable)?> in
                        self.trackEvent(.error)
                        return Just(nil)
                    })
            }.receive(on: Schedulers.main)
            .eraseToAnyPublisher()
    }

    func fundMovementsPublisher() -> AnyPublisher<Result<(FundRepresentable, FundMovementListRepresentable)?, Error>, Never> {
        return fundMovementsSubject
            .compactMap({ $0 })
            .flatMap { [unowned self] fund in
                self.getFundMovementsUsecase
                    .fechMovementsPublisher(fund: fund, pagination: nil, filters: nil)
                    .map { Result.success((fund: fund, movementList: $0)) }
                    .catch({ error in
                        Just(Result.failure(error))
                    })
            }.receive(on: Schedulers.main)
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

extension FundHomeViewModel: AutomaticScreenActionTrackable {
    var trackerManager: TrackerManager {
        return dependencies.external.resolve()
    }

    var trackerPage: FundPage {
        return FundPage()
    }
}
