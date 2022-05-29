//
//  LoanHomeCoordinator.swift
//  Pods
//
//  Created by Juan Jose Acosta on 17/2/22.
//

import CoreFoundationLib
import OpenCombine
import CoreDomain
import Localization

enum LoanDetailState: State {
    case idle
    case configurationLoaded(LoanDetailConfigRepresentable)
    case dataLoaded(LoanRepresentable)
    case detailLoaded(LoanDetailRepresentable)
    case allInfoLoaded((loan: LoanRepresentable, products: [LoanDetailProduct]))
}

final class LoanDetailViewModel: DataBindable {
    private let dependencies: LoanDetailDependenciesResolver
    private let stateSubject = CurrentValueSubject<LoanDetailState, Never>(.idle)
    private var subscriptions: Set<AnyCancellable> = []
    var state: AnyPublisher<LoanDetailState, Never>
    @BindingOptional var loan: LoanRepresentable?
    @BindingOptional var loanDetail: LoanDetailRepresentable?
    
    var dataBinding: DataBinding {
        return dependencies.resolve()
    }

    init(dependencies: LoanDetailDependenciesResolver) {
        self.dependencies = dependencies
        state = stateSubject.eraseToAnyPublisher()
    }
    
    func viewDidLoad() {
        guard let loan = self.loan else { return }
        subscribeLoanDetailInfo()
        subscribeLoanDetailConfiguration()
        stateSubject.send(.dataLoaded(loan))
        if let loanDetail = self.loanDetail {
            stateSubject.send(.detailLoaded(loanDetail))
        } else {
            subscribeDetail()
        }
        self.trackScreen()
    }
    
    func didTapOnShare() {
        guard let loanDetail = self.loanDetail, let shared = loanDetail.linkedAccountDesc else { return }
        let loanShareable = LoanShareable(shared: shared )
        self.coordinator.share(loanShareable, type: .text)
        trackEvent(.copyAccount, parameters: [:])
    }
    
    func didSelectMenu() {
        coordinator.didSelectMenu()
    }
    
    func didSelectBack() {
        coordinator.dismiss()
    }
    
    func copyContractAccount() {
        trackEvent(.copyContract, parameters: [:])
    }
}

private extension LoanDetailViewModel {
    var currentLocale: Locale {
        let stringLoader: StringLoader = dependencies.external.resolve()
        let identifier = stringLoader.getCurrentLanguage().languageType.rawValue
        return Locale(identifier: identifier)
    }
    
    var getDetailConfigUseCase: GetLoanDetailConfigUseCase {
        self.dependencies.resolve()
    }
    
    var getLoanDetailUsecase: GetLoanDetailUsecase {
        return dependencies.external.resolve()
    }
    
    var coordinator: LoanDetailCoordinator {
        return dependencies.resolve()
    }
}

// MARK: Subscriptions
private extension LoanDetailViewModel {
    func subscribeLoanDetailConfiguration() {
        self.getConfigurationPublished()
            .sink { [unowned self] config in
                self.stateSubject.send(.configurationLoaded(config))
            }.store(in: &subscriptions)
    }
    
    func subscribeDetail() {
        guard let loan = self.loan else { return }
        self.getDetailPublished(loan: loan)
            .compactMap { $0 }
            .sink { [unowned self] loanDetail in
                self.stateSubject.send(.detailLoaded(loanDetail))
            }.store(in: &subscriptions)
    }
    
    func subscribeLoanDetailInfo() {
        let loadLoanPublisher = self.state
            .case { LoanDetailState.dataLoaded }
        let loadConfigPublisher = self.state
            .case { LoanDetailState.configurationLoaded }
        
        let loadDetailPublisher = self.state
            .case { LoanDetailState.detailLoaded }
        
        Publishers.Zip3(loadLoanPublisher, loadConfigPublisher, loadDetailPublisher)
            .sink(receiveValue: { [self] loan, configuration, detail in
                let products = LoanDetailProductsBuilder(
                    loan: loan,
                    detail: detail,
                    config: configuration,
                    locale: currentLocale)
                    .getProducts()
                self.stateSubject.send(.allInfoLoaded((loan, products)))
            }).store(in: &subscriptions)
    }
}

// MARK: Publishers
private extension LoanDetailViewModel {
    func getConfigurationPublished() -> AnyPublisher<LoanDetailConfigRepresentable, Never> {
        return getDetailConfigUseCase
            .fetchConfiguration()
            .receive(on: Schedulers.main)
            .eraseToAnyPublisher()
    }
    
    func getDetailPublished(loan: LoanRepresentable) -> AnyPublisher<LoanDetailRepresentable?, Never> {
        return getLoanDetailUsecase
            .fechDetailPublisher(loan: loan)
            .map { $0 }
            .replaceError(with: nil)
            .receive(on: Schedulers.main)
            .eraseToAnyPublisher()
    }
}

extension LoanDetailViewModel: AutomaticScreenActionTrackable {
    var trackerManager: TrackerManager {
        return dependencies.external.resolve()
    }
    
    var trackerPage: LoanDetailPage {
        return LoanDetailPage()
    }
}
