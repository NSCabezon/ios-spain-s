//
//  SceneViewModel.swift
//  TransferOperatives
//
//  Created by Francisco del Real Escudero on 3/12/21.
//

import OpenCombine
import CoreDomain
import CoreFoundationLib

enum OneTransferHomeState: State {
    case idle
    case disableFavoritesCarousel
    case disableNewFavoriteButton
    case disableRecentAndScheduledTransfers
    case disableHelpFooter
    case receivedPayee([PayeeRepresentable])
    case recentAndScheduledTransfers([TransferRepresentable])
    case sendMoneyActionsLoaded([SendMoneyHomeActionType?])
    case faqsLoaded(OneFooterData)
    case newSendType(OneAdditionalFavoritesActionsViewModel.ViewType)
}

final class OneTransferHomeViewModel: DataBindable {
    private var subscriptions: Set<AnyCancellable> = []
    private let dependencies: OneTransferHomeDependenciesResolver
    private let stateSubject = CurrentValueSubject<OneTransferHomeState, Never>(.idle)
    var state: AnyPublisher<OneTransferHomeState, Never>
    
    private var payeeList: [PayeeRepresentable] = []
    
    var locations: [PullOfferLocation] {
        return [PullOfferLocation(stringTag: TransferPullOffers.donationTransferOffer,
                                  hasBanner: false, pageForMetrics: trackerPage.page)]
    }
    
    init(dependencies: OneTransferHomeDependenciesResolver) {
        self.dependencies = dependencies
        state = stateSubject.eraseToAnyPublisher()
    }
    
    func viewDidLoad() {
        loadFavorites()
        loadRecentAndScheduled()
        subscribeSendMoneyActions()
        loadFaqs()
        loadNewSendButton()
        trackScreen()
    }
    
    var dataBinding: DataBinding {
        return dependencies.resolve()
    }
    
    func didSelectSendMoneyAction(_ actionType: SendMoneyHomeActionType) {
        switch actionType {
        case .transfer:
            coordinator.goToNewTransfer()
            trackEvent(.transfer, parameters: [:])
        case .transferBetweenAccounts:
            trackEvent(.switches, parameters: [:])
            coordinator.goToNewInternalTransfer()
        case .atm:
            coordinator.goToAtm()
        case .scheduleTransfers:
            trackEvent(.scheduled, parameters: [:])
            coordinator.goToScheduledTransfers()
        case .donations(let offer):
            coordinator.goToOffer(offer)
        case .reuse:
            coordinator.goToReuse()
        case .custom(_, _, _, _, let offer):
            if let offer = offer {
                coordinator.goToOffer(offer)
            } else {
                coordinator.goToCustomSendMoneyAction(actionType)
            }
        }
    }
}

extension OneTransferHomeViewModel {
    func showAllFavorites() {
        trackEvent(.seeFavorites, parameters: [:])
        let booleanFeatureFlag: BooleanFeatureFlag = dependencies.external.resolve()
        booleanFeatureFlag.fetch(CoreFeatureFlag.oneFavoriteList)
            .filter { $0 == true }
            .sink { [unowned self] _ in
                coordinator.goToContactsList()
            }.store(in: &subscriptions)
        booleanFeatureFlag.fetch(CoreFeatureFlag.oneFavoriteList)
            .filter { $0 == false }
            .sink { [unowned self] _ in
                coordinator.showComingSoon()
            }.store(in: &subscriptions)
    }
    
    func showHistorical() {
        trackEvent(.history, parameters: [:])
        coordinator.goToSeeHistorical()
    }
    
    func showPastTransfer(_ transfer: TransferRepresentable) {
        if transfer.typeOfTransfer == .emitted {
            trackEvent(.emmited, parameters: [:])
        } else {
            trackEvent(.received, parameters: [:])
        }
        coordinator.goToPastTransfer(transfer: transfer, launcher: self)
    }
    
    func showSearch() {
        coordinator.showSearch()
    }
    
    func showTooltip() {
        trackEvent(.tooltip, parameters: [:])
        coordinator.showTooltip()
    }
    
    func showNewTransfer() {
        trackEvent(.newSend, parameters: [:])
        coordinator.goToNewTransfer()
    }
    
    func showNewContact() {
        trackEvent(.newContact, parameters: [:])
        coordinator.goToNewContact()
    }
    
    func showContactDetail(_ contactName: String) {
        guard let contact = payeeList.first(where: { $0.payeeAlias?.lowercased() == contactName.lowercased() }) else { return }
        trackEvent(.favouriteDetail, parameters: [:])
        coordinator.goToContactDetail(contact: contact, launcher: self)
    }
    
    func showMenu() {
        coordinator.showMenu()
    }
    
    func showTip(_ offer: OfferRepresentable?) {
        coordinator.goToOffer(offer)
    }
    
    func showVirtualAssistant() {
        trackEvent(.virtualAssistant, parameters: [:])
        coordinator.goToVirtualAssistant()
    }
    
    func recentAndScheduledSwipe() {
        trackEvent(.swipeRecentAndScheduled, parameters: [:])
    }
    
    func favoritesSwipe() {
        trackEvent(.swipeFavorites, parameters: [:])
    }
}

extension OneTransferHomeViewModel: ModuleLauncher {
    var dependenciesResolver: DependenciesResolver {
        return dependencies.external.resolve()
    }
}

// MARK: Subscriptions
extension OneTransferHomeViewModel {    
    func subscribeFavorites() {
        favoritesPublisher()
            .map { return Array($0.prefix(10)) }
            .replaceError(with: [])
            .sink { [unowned self] payees in
                self.payeeList = payees
                self.stateSubject.send(.receivedPayee(payees))
            }
            .store(in: &subscriptions)
    }
    
    func subscribeSendMoneyActions() {
        sendMoneyActionsPublisher()
            .sink { [unowned self] sendMoneyActions in
                self.stateSubject.send(.sendMoneyActionsLoaded(sendMoneyActions))
            }.store(in: &subscriptions)
    }
    
    func subscribeFaqs() {
        faqsPublisher()
            .sink { [unowned self] faqRepresentables in
                self.stateSubject.send(.faqsLoaded(faqRepresentables))
            }.store(in: &subscriptions)
    }
    
    func subscribeRecentAndScheduled() {
        recentAndScheduledPublisher()
            .sink { [unowned self] transfers in
                self.stateSubject.send(.recentAndScheduledTransfers(transfers))
            }
            .store(in: &subscriptions)
    }
}

// MARK: Publishers
private extension OneTransferHomeViewModel {
    func favoritesPublisher() -> AnyPublisher<[PayeeRepresentable], Error> {
        return getFavoritesUseCase
            .fetchContacts()
            .subscribe(on: Schedulers.background)
            .receive(on: Schedulers.main)
            .eraseToAnyPublisher()
    }
    
    func recentAndScheduledPublisher()-> AnyPublisher<[TransferRepresentable], Never> {
        return getAllTransfersUseCase
            .fetchTransfers()
            .map { output in
                return Array(
                    (output.emitted + output.received)
                        .sorted { !$0.lessThan(other: $1) && !$0.equalTo(other: $1) }
                        .prefix(20)
                )
            }
            .subscribe(on: Schedulers.background)
            .receive(on: Schedulers.main)
            .eraseToAnyPublisher()
    }
    
    func sendMoneyActionsPublisher() -> AnyPublisher<[SendMoneyHomeActionType], Never> {
        return getSendMoneyActionsUseCase
            .fetchSendMoneyActions(locations, page: trackerPage.page)
            .subscribe(on: Schedulers.background)
            .receive(on: Schedulers.main)
            .eraseToAnyPublisher()
    }
    
    func faqsPublisher() -> AnyPublisher<OneFooterData, Never> {
        return getFaqsUseCase
            .fetchFaqs(type: .transfersHome)
            .subscribe(on: Schedulers.background)
            .receive(on: Schedulers.main)
            .eraseToAnyPublisher()
    }
}

private extension OneTransferHomeViewModel {
    func loadFavorites() {
        if visibilityModifier.shouldShowFavoritesCarousel {
            subscribeFavorites()
        } else {
            stateSubject.send(.disableFavoritesCarousel)
        }
        if !visibilityModifier.shouldShowNewFavoriteOption {
            stateSubject.send(.disableNewFavoriteButton)
        }
    }
    
    func loadRecentAndScheduled() {
        if visibilityModifier.shouldShowRecentAndScheduledCarousel {
            subscribeRecentAndScheduled()
        } else {
            stateSubject.send(.disableRecentAndScheduledTransfers)
        }
    }
    
    func loadNewSendButton() {
        let newSendType = visibilityModifier.newTransferType
        stateSubject.send(.newSendType(newSendType))
    }
    
    func loadFaqs() {
        if visibilityModifier.shouldShowHelpFooter {
            subscribeFaqs()
        } else {
            stateSubject.send(.disableHelpFooter)
        }
    }
}

private extension OneTransferHomeViewModel {
    var coordinator: OneTransferHomeCoordinator {
        return dependencies.resolve()
    }
    
    var getFavoritesUseCase: GetReactiveContactsUseCase {
        return dependencies.external.resolve()
    }
    
    var getAllTransfersUseCase: GetAllTransfersReactiveUseCase {
        return dependencies.external.resolve()
    }
    
    var getSendMoneyActionsUseCase: GetSendMoneyActionsUseCase {
        return dependencies.external.resolve()
    }
    
    var getFaqsUseCase: GetOneFaqsUseCase {
        return dependencies.resolve()
    }

    var visibilityModifier: OneTransferHomeVisibilityModifier {
        return dependencies.external.resolve()
    }
}

extension OneTransferHomeViewModel: AutomaticScreenEmmaActionTrackable {
    var trackerPage: OneTransferPage {
        let emmaTrackEventList: EmmaTrackEventListProtocol = self.dependencies.external.emmaTrackEventListProtocol()
        let emmaToken = emmaTrackEventList.transfersEventID
        return OneTransferPage(emmaToken: emmaToken)
    }
    var trackerManager: TrackerManager {
        return dependencies.external.trackerManager()
    }
}
