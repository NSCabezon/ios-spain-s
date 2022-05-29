//
//  PrivateMenuViewModel.swift
//  PrivateMenu
//
//  Created by Boris Chirino Fernandez on 16/12/21.
//

import UI
import CoreFoundationLib
import OpenCombine
import CoreDomain
import OpenCombineDispatch

enum PrivateMenuState: State {
    case idle
    case menuOptions([PrivateMenuOptionRepresentable])
    case footerOptions([PrivateMenuFooterOptionRepresentable])
    case isDigitalProfileEnabled(Bool)
    case digitalProfilePercentage(Double)
    case nameOrAlias(NameRepresentable)
    case avatarImage(Data)
    case personalManagerBadge(Bool)
    case menuVisible
    case willShowMenu(PrivateMenuOptions)
    case yourManager(PersonalManagerRepresentable)
    case showCoachManager(ManagerCoachmarkInfoRepresentable)
    case didHideMenu
}

final class PrivateMenuViewModel: DataBindable {
    private enum Constants {
        static let salesforceServiceID: Double = 2.0
    }
    private let dependencies: PrivateMenuDependenciesResolver
    private let stateSubject = CurrentValueSubject<PrivateMenuState, Never>(.idle)
    private var anySubscriptions: Set<AnyCancellable> = []
    private var currentSelection: PrivateMenuOptions = .globalPosition
    private var optionsBuffer = [PrivateMenuOptionRepresentable]()
    var state: AnyPublisher<PrivateMenuState, Never>
    var dataBinding: DataBinding {
        return dependencies.resolve()
    }
    
    init(dependencies: PrivateMenuDependenciesResolver) {
        self.dependencies = dependencies
        self.state = stateSubject.eraseToAnyPublisher()
    }
    
    func viewDidLoad() {
        optionsBuffer.removeAll()
        subscribeCoachShown()
        subscribeMenuOptions()
        subscribeMenuFooterOptions()
        subscribeIsDigitalProfileEnabled()
        subscribeNameOrAlias()
        subscribeAvatarImage()
        subscribePersonalManager()
        subscribePrivateMenuEventsRepository()
        subscribeGetAllPersonalManagers()
        subscribeDisplayManager()
    }
}

// MARK: - UseCases

extension PrivateMenuViewModel {
    var footerOptionsUseCase: GetPrivateMenuFooterOptionsUseCase {
        dependencies.external.resolve()
    }
    
    var menuOptionsUseCase: GetPrivateMenuOptionsUseCase {
        dependencies.external.resolve()
    }
    
    var digitalProfilePercentageUseCase: GetDigitalProfilePercentageUseCase {
        dependencies.external.resolve()
    }
    
    var nameOrAliasUseCase: GetNameUseCase {
        dependencies.external.resolve()
    }
    
    var avatarImageUseCase: GetAvatarImageUseCase {
        dependencies.external.resolve()
    }
    
    var personalManagerUseCase: GetPersonalManagerUseCase {
        dependencies.external.resolve()
    }
    
    var privateMenuEventsRepository: PrivateMenuEventsRepository {
        dependencies.external.resolve()
    }
    var offers: GetCandidateOfferUseCase {
        return dependencies.external.resolve()
    }
    var sanflix: GetSanflixUseCase {
        return dependencies.external.resolve()
    }
    var marketplaceUseCase: GetMarketplaceWebViewConfigurationUseCase {
        return dependencies.external.resolve()
    }
    var locationPermissionsManagerProtocol: LocationPermissionsManagerProtocol {
        return dependencies.external.resolve()
    }
    var displayManagerUseCase: DisplayManagerPrivateMenuUseCase {
        return dependencies.external.resolve()
    }
}

// MARK: - Subscriptions

private extension PrivateMenuViewModel {
    func subscribeMenuFooterOptions() {
        menuFooterOptionPublisher()
            .sink {[unowned self] options in
                self.stateSubject.send(.footerOptions(options))
            }.store(in: &anySubscriptions)
    }
    
    func subscribeMenuOptions() {
        menuOptionPublisher()
            .sink { [unowned self] options in
                optionsBuffer.append(contentsOf: options)
                self.stateSubject.send(.menuOptions(options))
            }.store(in: &anySubscriptions)
    }
    
    func subscribeIsDigitalProfileEnabled() {
        isDigitalProfileEnabledPublisher()
            .sink { isEnabled in
                self.stateSubject.send(.isDigitalProfileEnabled(isEnabled))
                if isEnabled {
                    self.subscribeDigitalProfilePercentage()
                }
            }
            .store(in: &anySubscriptions)
    }
    
    func subscribeDigitalProfilePercentage() {
        digitalProfilePercentagePublisher()
            .sink(receiveCompletion: { _ in }, receiveValue: {[unowned self] percentage in
                self.stateSubject.send(.digitalProfilePercentage(percentage))
            })
            .store(in: &anySubscriptions)
    }
    
    func subscribeNameOrAlias() {
        nameOrAliasPublisher()
            .sink {[unowned self] name in
                self.stateSubject.send(.nameOrAlias(name))
            }.store(in: &anySubscriptions)
    }
    
    func subscribeAvatarImage() {
        avatarImagePublisher()
            .sink(receiveCompletion: { _ in }, receiveValue: { [unowned self] image in
                guard let image = image else { return }
                self.stateSubject.send(.avatarImage(image))
            })
            .store(in: &anySubscriptions)
    }

    func subscribePersonalManager() {
        personalManagerPublisher()
            .sink { anyUnread in
                self.stateSubject.send(.personalManagerBadge(anyUnread))
            }
            .store(in: &anySubscriptions)
    }
    
    func subscribePrivateMenuEventsRepository() {
        privateMenuEventsRepository.eventsPublisher()
            .case(PrivateMenuEvents.didShowMenu)
            .sink {[unowned self] in
                self.stateSubject.send(.menuVisible)
            }.store(in: &anySubscriptions)
        
        privateMenuEventsRepository.eventsPublisher()
            .case(PrivateMenuEvents.willShowMenu)
            .sink {[unowned self] hightlightedOption in
                for (index, element) in optionsBuffer.enumerated() {
                    var mutatingOption = element
                    mutatingOption.isHighlighted = element.type == hightlightedOption
                    optionsBuffer[index] = mutatingOption
                }
                self.stateSubject.send(.menuOptions(optionsBuffer))
            }.store(in: &anySubscriptions)
        
        privateMenuEventsRepository.eventsPublisher()
            .case (PrivateMenuEvents.didHideMenu)
            .sink { _ in
                self.stateSubject.send(.didHideMenu)
            }
            .store(in: &anySubscriptions)
    }
    
    func subscribeOffer(_ option: PrivateMenuOptions) {
        guard let location = option.location else { return }
        offers.fetchCandidateOfferPublisher(location: location)
            .receive(on: Schedulers.main)
            .sink { _ in
            } receiveValue: { [unowned self] offer in
                self.didSelectOffer(offer)
            }
            .store(in: &anySubscriptions)
    }
    
    func subscribeSanflix() {
        sanflixPublisher()
            .sink { [unowned self] representable in
                guard representable.isEnabledExploreProductsInMenu else {
                    goToComingSoon()
                    return
                }
                if representable.isSanflixEnabled, let offer = representable.offerRepresentable {
                    didSelectOffer(offer)
                } else {
                    didSelectContractView()
                }
            }
            .store(in: &anySubscriptions)
    }
    
    func subscribeMarketPlace() {
        locationPermissionsManagerProtocol
            .getCurrentLocation { [weak self] latitude, longitude in
                guard let self = self else { return }
                var location = (Double(0), Double(0))
                if let latitude = latitude, let longitude = longitude {
                    location = (latitude, longitude)
                }
                self.marketPlacePublisher(location: location)
                    .sink(receiveCompletion: { value in
                    }, receiveValue: { [unowned self] configuration in
                        self.didSelectWebConfiguration(configuration)
                    })
                    .store(in: &self.anySubscriptions)
            }
    }
    
    func subscribeGetAllPersonalManagers() {
        allPersonalManagersPublishers()
            .sink { _ in
            } receiveValue: { [unowned self] managers in
                guard let yourManager = managers.first else { return }
                self.stateSubject.send(.yourManager(yourManager))
            }
            .store(in: &self.anySubscriptions)
    }
    
    func subscribeDisplayManager() {
        displayManager
            .sink { [unowned self] info in
                self.stateSubject.send(.showCoachManager(info))
            }
            .store(in: &anySubscriptions)
    }
    
    func subscribeCoachShown() {
        coachShown
            .sink { _ in
            }
            .store(in: &anySubscriptions)
    }
}

// MARK: - Publishers

extension PrivateMenuViewModel {
    func allPersonalManagersPublishers() ->  AnyPublisher<[PersonalManagerRepresentable], Error> {
        return personalManagerUseCase
            .fetchPersonalManager()
            .receive(on: Schedulers.main)
            .eraseToAnyPublisher()
    }
    
    func menuFooterOptionPublisher() -> AnyPublisher<[PrivateMenuFooterOptionRepresentable], Never> {
        return footerOptionsUseCase
            .fetchFooterOptions()
            .receive(on: Schedulers.main)
            .eraseToAnyPublisher()
    }
    
    func menuOptionPublisher() -> AnyPublisher<[PrivateMenuOptionRepresentable], Never> {
        return menuOptionsUseCase
            .fetchMenuOptions()
            .receive(on: Schedulers.main)
            .eraseToAnyPublisher()
    }
    
    func isDigitalProfileEnabledPublisher() -> AnyPublisher<Bool, Never> {
        return digitalProfilePercentageUseCase
            .fetchIsDigitalProfileEnabled()
            .receive(on: Schedulers.main)
            .eraseToAnyPublisher()
    }
    
    func digitalProfilePercentagePublisher() -> AnyPublisher<Double, Error> {
        return digitalProfilePercentageUseCase
            .fetchDigitalProfilePercentage()
            .receive(on: Schedulers.main)
            .eraseToAnyPublisher()
    }
    
    func nameOrAliasPublisher() -> AnyPublisher<NameRepresentable, Never> {
        return nameOrAliasUseCase
            .fetchNameOrAlias()
            .receive(on: Schedulers.main)
            .eraseToAnyPublisher()
    }
    
    func avatarImagePublisher() -> AnyPublisher<Data?, Never> {
        return avatarImageUseCase
            .fetchAvatarImage()
            .receive(on: Schedulers.main)
            .eraseToAnyPublisher()
    }
    
    func personalManagerPublisher() -> AnyPublisher<Bool, Never> {
        return personalManagerUseCase
            .unreadNotification()
            .receive(on: Schedulers.main)
            .eraseToAnyPublisher()
    }
    
    func sanflixPublisher() -> AnyPublisher<SanflixContractInfoRepresentable, Never> {
        return sanflix
            .fetchSanflix()
            .receive(on: Schedulers.main)
            .eraseToAnyPublisher()
    }
    
    func marketPlacePublisher(location: (latitude: Double, longitude: Double)?) -> AnyPublisher<WebViewConfiguration, Error> {
        return marketplaceUseCase
            .fetchWebViewConfiguration(location: location)
            .receive(on: Schedulers.main)
            .eraseToAnyPublisher()
    }
    
    var displayManager: AnyPublisher<ManagerCoachmarkInfoRepresentable, Never> {
        return displayManagerUseCase
            .fetchManagerCoachmarkInfo()
            .receive(on: Schedulers.main)
            .eraseToAnyPublisher()
    }
    
    var coachShown: AnyPublisher<Void, Never> {
        return displayManagerUseCase
            .updateManagerShown(false)
            .receive(on: Schedulers.main)
            .eraseToAnyPublisher()
    }
}

// MARK: - Footer Navigation

extension PrivateMenuViewModel {
    var coordinator: PrivateMenuCoordinator {
        dependencies.resolve()
    }
    
    func didSelectPersonalArea() {
        coordinator.gotoPersonalArea()
    }
    
    func didSelectSecurity() {
        coordinator.gotoSecurity()
    }
    
    func didSelectATM() {
        coordinator.gotoBranchLocator()
    }
    
    func didSelectHelpCenter() {
        coordinator.gotoHelpCenter()
    }
    
    func didSelectMyManager() {
        coordinator.gotoMyManager()
    }
    
    func didSelectBack() {
        coordinator.gotoPG()
    }
    
    func didSelectLogOut() {
        coordinator.logout()
    }
    
    func didSelectHelpUs() {
        coordinator.gotoOpinator()
    }
    
    func closeSideMenu() {
        coordinator.closeSideMenu()
    }
    
    func didSelectMyManager(_ offer: OfferRepresentable?) {
        guard let offer = offer else { return }
        didSelectOffer(offer)
    }
}

// MARK: - Forward Navigation

private extension PrivateMenuViewModel {
    func didSelectSantanderBoots() {
        coordinator.gotoSantanderBoots()
    }
    
    func myMoneyManager() {
        coordinator.gotoMyManager()
    }
    
    func productsAndOffers() {
        coordinator.gotoProductsAndOffers()
    }
    
    func homeEco() {
        coordinator.gotoHomeEco()
    }
    
    func importantInformation() {
        coordinator.gotoImportantInformation()
    }
    
    func sendMoney() {
        coordinator.gotoSendMoney()
    }
    
    func submenu(_ privateSubMenuOptionType: PrivateSubMenuOptionType) {
        coordinator.gotoSubmenu(privateSubMenuOptionType)
    }
    
    func blik() {
        coordinator.gotoBlik()
    }
    
    func mobileAuthorization() {
        coordinator.gotoMobileAuthorization()
    }
    
    func becomeClient() {
        coordinator.gotoBecomeClient()
    }
    
    func currencyExchange() {
        coordinator.gotoCurrencyExchange()
    }
    
    func services() {
        coordinator.gotoServices()
    }
     
    func memberGetMember() {
        coordinator.gotoMemberGetMember()
    }
    
    func didSelectFinancing() {
        coordinator.gotoFinancing()
    }
    
    func didSelectBillAndTaxes() {
        coordinator.gotoBillAndTaxes()
    }
    
    func didSelectAnalysisArea() {
        coordinator.gotoAnalysisArea()
    }
    
    func didSelectTopUps() {
        coordinator.gotoTopUps()
    }
    
    func didSelectContractView() {
        coordinator.goToContractView()
    }
    
    func didSelectWebConfiguration(_ config: WebViewConfiguration) {
        coordinator.goToWebConfiguration(config)
    }
    
    func didSelectOffer(_ offer: OfferRepresentable) {
        coordinator.goToOffer(offer)
    }
    
    func goToComingSoon() {
        coordinator.goToComingSoon()
    }
}

// MARK: - Options Navigation

extension PrivateMenuViewModel {
    func didSelectOption(_ option: PrivateMenuOptionRepresentable) {
        currentSelection = option.type
        switch option.type {
        case .globalPosition:
            didSelectBack()
        case .santanderBoots:
            didSelectSantanderBoots()
        case .myMoneyManager:
            myMoneyManager()
        case .productsAndOffers:
            productsAndOffers()
        case .myHomeManager:
            homeEco()
        case .importantInformation:
            importantInformation()
        case .transfers:
            sendMoney()
        case .myProducts:
            submenu(.myProducts)
        case .blik:
            blik()
        case .mobileAuthorization:
            mobileAuthorization()
        case .becomeClient:
            becomeClient()
        case .currencyExchange:
            currencyExchange()
        case .services:
            services()
        case .memberGetMember:
            memberGetMember()
        case .financing:
            didSelectFinancing()
        case .bills:
            didSelectBillAndTaxes()
        case .analysisArea:
            didSelectAnalysisArea()
        case .topUps:
            didSelectTopUps()
        case .otherServices:
            submenu(.otherServices)
        case .sofiaInvestments:
            submenu(.sofia)
        case .world123:
            submenu(.world123)
        case .santanderOne1:
            subscribeOffer(.santanderOne1)
        case .santanderOne2:
            subscribeOffer(.santanderOne2)
        case .myHome:
            subscribeOffer(.myHome)
        case .contract:
            subscribeSanflix()
        case .marketplace:
            subscribeMarketPlace()
        }
    }
}
