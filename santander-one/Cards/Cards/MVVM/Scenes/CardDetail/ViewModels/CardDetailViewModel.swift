import UI
import CoreFoundationLib
import Foundation
import OpenCombine
import CoreDomain

enum CardDetailState: State {
    case idle
    case configurationLoaded(CardDetailConfiguration)
    case cardDetailLoaded(CardDetailRepresentable)
    case dataLoaded(CardDetail)
    case calculateExpenses(AmountRepresentable)
    case detailError(LocalizedError)
    case changeAlias
    case changeAliasError(LocalizedError)
}

final class CardDetailViewModel: DataBindable {
    @BindingOptional var selectedCard: CardRepresentable?
    @BindingOptional var userId: String?
    private var subscriptions: Set<AnyCancellable> = []
    private let dependencies: CardDetailDependenciesResolver
    private let stateSubject = CurrentValueSubject<CardDetailState, Never>(.idle)
    private let cardDetailSubject = PassthroughSubject<CardDetailState, Never>()
    private var cardDetail: CardDetail?
    private var cardDetailRepresentable: CardDetailRepresentable?
    var state: AnyPublisher<CardDetailState, Never>
    
    var dataBinding: DataBinding {
        return dependencies.resolve()
    }
    
    var globalPositionReloader: GlobalPositionReloader {
        return dependencies.external.resolve()
    }
    
    init(dependencies: CardDetailDependenciesResolver) {
        self.dependencies = dependencies
        state = stateSubject.eraseToAnyPublisher()
    }
    
    func viewDidLoad() {
        guard let card = self.selectedCard else { return }
        subscribeData()
        subscribeDetail(card: card)
        subscribeCalculateExpenses(card: card)
        self.trackScreen()
    }
    
    func didSelectGoBack() {
        coordinator.dismiss()
    }
    
    func didSelectOpenMenu() {
        coordinator.openMenu()
    }
    
    func didSelectActiveCard() {
        guard let card = self.selectedCard else { return }
        coordinator.activeCard(card: card)
    }
    
    func reloadGlobalPosition() {
        globalPositionReloader.reloadGlobalPosition()
        guard let card = self.selectedCard else { return }
        subscribeGlobalPosition(card: card)
    }
    
    func changeAlias(newAlias: String) {
        guard let card = self.selectedCard else { return }
        trackEvent(.changeAlias, parameters: [:])
        subscribeChangeAliasData(card: card, newAlias: newAlias)
    }
    
    func didTapOnShowPAN() {
        guard let card = self.selectedCard else { return }
        coordinator.showPAN(card: card)
    }

    func didTapOnSharePAN() {
        guard let shareData = cardDetail else { return }
        shareData.shareType = .pan
        trackEvent(.copyPan, parameters: [:])
        coordinator.share(shareData, type: .text)
    }

    func didTapOnShareAccountNumber() {
        guard let shareData = cardDetail else { return }
        shareData.shareType = .accountNumber
        coordinator.share(shareData, type: .text)
    }
}

private extension CardDetailViewModel {
    var coordinator: CardDetailCoordinator {
        return dependencies.resolve()
    }
    
    var getCardDetailConfigurationUseCase: GetCardDetailConfigurationUseCase {
        return dependencies.external.resolve()
    }
    
    var getCardDetailUseCase: GetCardDetailUseCase {
        return dependencies.resolve()
    }
    
    var getCardsExpensesCalculationUseCase: GetCardsExpensesCalculationUseCase {
        return dependencies.external.resolve()
    }
    
    var getChangeAliasCardUseCase: ChangeAliasCardUseCase {
        return dependencies.resolve()
    }
}

// MARK: - Subscriptions
private extension CardDetailViewModel {
    func subscribeConfiguration(card: CardRepresentable, cardDetail: CardDetailRepresentable) {
        cardDetailConfigurationPublisher(card: card, cardDetail: cardDetail)
            .sink { [unowned self] configuration in
                self.stateSubject.send(.configurationLoaded(configuration))
            }.store(in: &subscriptions)
    }
    
    func subscribeDetail(card: CardRepresentable) {
        cardDetailPublisher(card: card)
            .sink { [unowned self] completion in
                if case .failure(let error) = completion {
                    self.stateSubject.send(.detailError(error as LocalizedError))
                }
                
            } receiveValue: { [unowned self] detail in
                self.stateSubject.send(.cardDetailLoaded(detail))
                subscribeConfiguration(card: card, cardDetail: detail)
                
            }
            .store(in: &subscriptions)
    }
    
    func subscribeCalculateExpenses(card: CardRepresentable) {
        calculateExpensesPublisher(card: card)
            .compactMap { $0 }
            .sink { [unowned self] expenses in
                self.stateSubject.send(.calculateExpenses(expenses))
            }.store(in: &subscriptions)
    }
    
    func subscribeData() {
        
        let detailPublisher = self.state
            .case(CardDetailState.cardDetailLoaded)
        
        let configurationPublisher = self.state
            .case(CardDetailState.configurationLoaded)
        
        let expensesPublisher = self.state
            .case(CardDetailState.calculateExpenses)
        
        Publishers.Zip3(configurationPublisher, detailPublisher, expensesPublisher)
            .sink( receiveValue: { [self] configuration, detail, expenses in
                configuration.cardDetail = detail
                self.cardDetail = CardDetail(card: configuration.card, cardDetail: detail, cardDetailConfiguration: configuration, dependencies: self.dependencies)
                self.cardDetail?.monthBalance = expenses
                guard let detail = self.cardDetail else { return }
                self.stateSubject.send(.dataLoaded(detail))
            }
            )
            .store(in: &subscriptions)
    }
    
    func subscribeChangeAliasData(card: CardRepresentable, newAlias: String) {
        changeAliasCardPublisher(card: card, newAlias: newAlias)
            .sink { [unowned self] completion in
                if case .failure(let error) = completion {
                    self.stateSubject.send(.changeAliasError(error as LocalizedError))
                }
                
            } receiveValue: { [unowned self] _ in
                reloadGlobalPosition()
            }
            .store(in: &subscriptions)
    }
    
    func subscribeGlobalPosition(card: CardRepresentable) {
        globalPositionCardPublisher(card: card)
            .sink { [unowned self] completion in
                if case .failure(let error) = completion {
                    self.stateSubject.send(.changeAliasError(error as LocalizedError))
                }
                
            } receiveValue: { [unowned self] _ in
                self.stateSubject.send(.changeAlias)
            }
            .store(in: &subscriptions)
    }
}

// MARK: Publishers
private extension CardDetailViewModel {
    func cardDetailConfigurationPublisher(card: CardRepresentable, cardDetail: CardDetailRepresentable) -> AnyPublisher<CardDetailConfiguration, Never> {
        return getCardDetailConfigurationUseCase
            .fetchCardDetailConfiguration(card: card, cardDetail: cardDetail)
            .receive(on: Schedulers.main)
            .eraseToAnyPublisher()
    }
    
    func cardDetailPublisher(card: CardRepresentable) -> AnyPublisher<CardDetailRepresentable, Error> {
        return getCardDetailUseCase
            .fetchCardDetail(card: card)
            .receive(on: Schedulers.main)
            .eraseToAnyPublisher()
    }
    
    func calculateExpensesPublisher(card: CardRepresentable) -> AnyPublisher<AmountRepresentable, Never> {
        return getCardsExpensesCalculationUseCase
            .fetchExpensesCalculationPublisher(card: card)
            .receive(on: Schedulers.main)
            .eraseToAnyPublisher()
    }
    
    func changeAliasCardPublisher(card: CardRepresentable, newAlias: String) -> AnyPublisher<Void, Error> {
        return getChangeAliasCardUseCase
            .fetchChangeAliasCard(card: card, newAlias: newAlias)
            .receive(on: Schedulers.main)
            .eraseToAnyPublisher()
    }
    
    func globalPositionCardPublisher(card: CardRepresentable) -> AnyPublisher<CardRepresentable?, Never> {
        return getCardDetailUseCase
            .fetchCardGlobalPosition(card: card)
            .receive(on: Schedulers.main)
            .eraseToAnyPublisher()
    }
}

extension CardDetailViewModel: AutomaticScreenActionTrackable {
    var trackerManager: TrackerManager {
        dependencies.external.resolve()
    }

    var trackerPage: CardDetailPage {
        CardDetailPage()
    }
}
